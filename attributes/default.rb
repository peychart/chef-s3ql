#
# Cookbook Name:: chef-s3ql
# Attributes:: chef-s3ql
#
default['chef-s3ql']['authfilePath'] = ""
default['chef-s3ql']['sections'] = []
#Example:
#default['chef-s3ql']['sections'] = [
#  {
#    "name": "swift-backupfs",
#    "backend-login": "system:root",
#    "backend-password": "myPassword",
#    "fs-passphrase": "myFsPassphrase",
#    "storage-url": "swift://swiftauth.my.domain:8080/s3ql",
#    "device": "swift://swiftauth.my.domain:8080/s3ql",
#    "mountPoint": "/media/backupStorage",
#    "options":"no-ssl"
#  },
#  {
#    "name": "swift-anOtherfs",
#    ...
#  }
# ]
