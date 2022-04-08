module.exports = {
  kmsEncryptedHookUrl: process.env.KMS_ENCRYPTED_HOOK_URL, // encrypted slack webhook url
  unencryptedHookUrl: process.env.UNENCRYPTED_HOOK_URL, // unencrypted slack webhook url

  metrics: {
    SecurityGroupChanges: {
      // text in the sns message or topicname to match on to process this service type
      match_events_text:
        ["AuthorizeSecurityGroupIngress",
          "AuthorizeSecurityGroupEgress",
          "RevokeSecurityGroupIngress",
          "RevokeSecurityGroupEgress",
          "CreateSecurityGroup",
          "DeleteSecurityGroup"]
    }
  }
}
