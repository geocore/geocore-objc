# ObjectiveGeocore

**This is a very early version.**

ObjectiveGeocore is an Objective-C client library for accessing Geocore API server.

## Logging in to Geocore

Following sample code shows how to log in to Geocore through Facebook:
```objc
[[Geocore instance] autoLoginWithFacebookId:facebookId name:facebookName];
```
