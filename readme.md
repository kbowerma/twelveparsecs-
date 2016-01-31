# Introduction

This application is a Proof of Concept to show how Salesforce SmartSync can be used to handle offline data and synchronization with salesforce server.

## Requirements

This is an iOS application to be run in an iPhone/iPad device. It uses Pod to retrieve all its dependencies:

1. XCode 7.2
2. iOS SDK 8+
3. Salesforce SDK
4. SmartStore
5. SmartSync
6. WYPopoverController
7. FMDB

## Setup

1.  Run this code and login with member@topcoder.com / t0pc0d3r
2.  If you want to point it to you sfdc org here is the unmanaged package for the object setup:
 [unamangaged package](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t15000000l6nO)

See deployment guide in doc dir.  Please note the credinetials in the word doc wont work with this code because the developer used a namespace prefix which has been removed.

## Implementation information

This application was based on a sample provided by Salesforce team that demonstrates the usage of SmartStore and SmartSync functionalities.
It was extended to allow multiple soups to be stored in SmartStore for different objects defined in Salesforce. 

For this particular application it was used the Contact object and 2 new custom objects, Product and Sample Request.
To allow many-to-many relationship between Sample Request object and User object a junction object called Authorized_Users was created.

Since the Sample Request object depends on data from Contact and Product objects some care has been taken:

1. When a new Contact or Product is just created it can't be used in a Sample Request until it has been synchronized with the server and an unique ID has been provided.
2. Synchronization is always done in background so user never gets blocked.
3. Synchronization with server is only done if internet connection is online.
4. Synchronization is done automatically if some data was changed (new or edit), every 5 minutes (configurable in the device settings), when the device is online after being offline and changed data exists, or if requested manually by user.
