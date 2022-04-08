var AWS = require('aws-sdk')
var url = require('url')
var https = require('https')
var config = require('./config')
var _ = require('lodash')
var cwl = new AWS.CloudWatchLogs();
var cw = new AWS.CloudWatch();
var sns = new AWS.SNS({ apiVersion: '2010-03-31' });
var hookUrl



exports.handler = function (event, context) {
    var alarmName = event.detail.alarmName;
    var time = event.time;

    processEvent(event, context);


};

var handleCloudWatch = function (data, event, alarm) {
    sendEmail(generateEmailContent(data, alarm))
}


var handleCatchAll = function (event, context) {
    var record = event.Records[0]
    var subject = record.Sns.Subject
    var timestamp = new Date(record.Sns.Timestamp).getTime() / 1000
    var message = JSON.parse(record.Sns.Message)
    var color = 'warning'

    if (message.NewStateValue === 'ALARM') {
        color = 'danger'
    } else if (message.NewStateValue === 'OK') {
        color = 'good'
    }

    // Add all of the values from the event message to the Slack message description
    var description = ''
    for (key in message) {
        var renderedMessage = typeof message[key] === 'object' ? JSON.stringify(message[key]) : message[key]

        description = description + '\n' + key + ': ' + renderedMessage
    }

    var slackMessage = {
        text: '*' + subject + '*',
        attachments: [
            {
                color: color,
                fields: [
                    { title: 'Message', value: record.Sns.Subject, short: false },
                    { title: 'Description', value: description, short: false }
                ],
                ts: timestamp
            }
        ]
    }

    return _.merge(slackMessage, baseSlackMessage)
}

var processEvent = function (event, context) {
    var alarmName = event.detail.alarmName;
    var time = event.time;
    var messageNotification = null

    getWatchlogData(alarmName, time, function (err, data, alarm) {
        if (config.metrics.SecurityGroupChanges.match_events_text.includes(data.eventName)) {
            console.log(`processing ${data.eventName} notification`)
            messageNotification = handleCloudWatch(data, event, alarm)
        } else {
            console.error(`Event:${data.eventName} not found`)
            // messageNotification = handleCatchAll(event, context)
        }
    })
}



function getWatchlogData(alarmName, time, fn) {
    getAlarm(alarmName, function (err, data) {
        if (err) { console.log(err, err.stack) } // an error occurred
        else {
            const metrics = data.MetricAlarms[0]
            getMetricsFilter(data.MetricAlarms[0].MetricName, data.MetricAlarms[0].Namespace, function (err, data) {
                if (err) console.log('Error is:', err);
                else {
                    getFilterLogEvents(data.metricFilters[0].logGroupName, data.metricFilters[0].filterPattern, time, function (err, data) {
                        console.log(data)
                        fn(err, JSON.parse(data.events[0].message), metrics)
                    })
                }
            })
        }
    })
}

function getAlarm(alarm_name, fn) {
    var params = {
        AlarmNames: [
            alarm_name
        ]
    };
    cw.describeAlarms(params, fn);
}

function getMetricsFilter(metricName, metricNamespace, fn) {
    var requestParams = {
        metricName: metricName,
        metricNamespace: metricNamespace
    };
    cwl.describeMetricFilters(requestParams, fn);
}

function getFilterLogEvents(logGroupName, filterPattern, time, fn) {
    var timestamp = Date.parse(time);
    // var offset = new Date().getTime()
    var offset = Date.parse("2022-04-08T00:59:11Z")


    var parameters = {
        'logGroupName': logGroupName,
        'filterPattern': filterPattern,
        'startTime': timestamp,
        'endTime': offset
    };
    cwl.filterLogEvents(parameters, fn);
}

var sendEmail = function (structureMessage, callback) {
    var params = {
        Message: structureMessage.message, /* required */
        TopicArn: 'arn:aws:sns:ap-southeast-2:960722883904:CISAlarm',
        Subject: structureMessage.subject,
        MessageStructure: 'string'
    };
    console.log("===SENDING EMAIL===");

    var email = sns.publish(params).promise().then(function (data) {
        console.log(`Message ${params.Message} sent to the topic ${params.TopicArn}`);
        console.log("MessageID is " + data.MessageId);
    }).catch(function (err) {
        console.error(err, err.stack);
    });
}

function generateEmailContent(clouldTrail, alarm) {
    var date = new Date(clouldTrail.eventTime);

    customMessage = `You are receiving this email because your Amazon CloudWatch Alarm "${alarm.AlarmName}" in the ${clouldTrail.awsRegion} region has entered the ${alarm.StateValue} state, because ${alarm.StateReason}  at ${alarm.StateUpdatedTimestamp}
    
    View this alarm in the AWS Management Console:
    https://${clouldTrail.awsRegion}.console.aws.amazon.com/cloudwatch/home?region=${clouldTrail.awsRegion}#s=Alarms&alarm=${encodeURI(alarm.AlarmName)}
    
    Alarm Details:
    - Name: ${alarm.AlarmName}
    - Description: ${alarm.AlarmDescription}
    - AWS Account: ${clouldTrail.userIdentity.accountId}
    - Alarm Arn: ${alarm.AlarmArn}`;

    return { message: customMessage, subject: `ALARM: "${alarm.AlarmName}" in ${clouldTrail.awsRegion}` };
}