# Integration for iOS

## Requirements

- iOS 7.0+

## Installation

### CocoaPods

If you are using [Cocoapods](https://cocoapods.org/), add this line to your `Podfile`:

```ruby
pod 'Dusto', '~> 0.1.5'
```

Then run `pod install`.

> For more information on Cocoapods, check [their official documentation](https://guides.cocoapods.org/using/getting-started.html).

## Usage

> Suppose we are creating an App called `DustoApp`.

This SDK provides 2 main methods.

One for initialization with `ACCESS KEY` and `ACCESS SECRET`:

```object-c
+ (void)configureWithAccessKey:(NSString *)accessKey
                  accessSecret:(NSString *)accessSecret NS_SWIFT_NAME(configure(accessKey:accessSecret:));
```

One for sending validation to `https://dusto.top/`:

```object-c
- (void)validatePurchaseWithPurchaseID:(NSString *)purchaseID
                                userID:(nullable NSString *)userID
                            completion:(nullable void (^)(NSError * _Nullable error, BOOL valid))completion NS_SWIFT_NAME(validatePurchase(purchaseID:userID:completion:));
```

> [NOTICE] This SDK doesn't provides methods for getting `purchaseID` and `userID`. You have to get them by your own.
> For more details, please read the docs at [here](https://dusto.top/docs).

## Sample

Get more details in the sample project [`DustoDemo`](./DustoDemo). In order to help you get started quickly, we provide cheatsheets for you:

- https://github.com/dusto-top/Dusto/blob/ebc5e486caa2b3069960950a6e10b78841d52db2/DustoDemo/AppDelegate.m#L18
- https://github.com/dusto-top/Dusto/blob/ebc5e486caa2b3069960950a6e10b78841d52db2/DustoDemo/ViewController.m#L88

## License

MIT


