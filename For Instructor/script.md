## Introduction

Hey what's up everybody, this is Ray. In today's screencast, I'm going to introduce you to a really cool iOS framework called ReplayKit.

ReplayKit records the screen and audio of your application. You can also add your own voice commentary or add your expressions using the the front facing camera to make your recordings personal or provide extra context. It allows your users to play back, scrub and trim their recordings and finally share their recordings to their favorite social networks and video destination sites. ReplayKit generates high-quality HD recordings that will look great on TV's, websites and mobile devices.

Although available since iOS 9, ReplayKit has added some great APIs in both iOS 10 and 11, allowing developers to live broadcast their recordings to service providers like Twitch. Uncharacteristically, ReplayKit doesn't work in the iOS Simulator, so everything you'll see here will be shown on device.

Before we begin, I just want to give a shout out to the Vijay Sharma and to the guy that wrote this app https://www.raywenderlich.com/146407/gameplaykit-tutorial-artificial-intelligence

Adding ReplayKit to your app is super easy, so let's dive in.

## Demo 1

In this demo, we're using an app written using SpriteKit, but ReplayKit can be used with apps written purely in UIKit. We'll start by importing ReplayKit into our project by adding the following header to our Scene.

```
import ReplayKit
```

We've already added a button to start a recording, and the callback to handle the touch event. In order to start recording using ReplayKit, in the body of the method, we'll first get a handle to `RPScreenRecorder`. We'll call `startRecording` passing in a callback. In the callback we'll update the state of our button so that users know we're currently recording, and if there's an error, we'll just print that to the console.

```
let recorder = RPScreenRecorder.shared()
recorder.startRecording { (error) in
  guard error == nil else {
    print("Failed to start recording")
    return
  }

  self.recordButton.texture = SKTexture(imageNamed:"stop")
}
```

## Interlude 1

And that's all it takes to record your app using ReplayKit. Now you might be tempted to build and run, but before you do that, let's quickly see what's going on under the hood

[slide 01]

When your app calls `startRecording`, `RPScreenRecorder` speaks with the ReplayKit daemon running in the OS. This daemon will capture your screen into a video recording and store it in file only accessible to the daemon. This daemon uses low level video and audio APIs to capture the video to keep performance impact on your app very low. ReplayKit will also avoid recording the system UI, this means any notifications that your user might get while recording won't show up in the final movie.

Next let's stop the recording and give your users the ability to share it.

## Demo 2

We can use `RPScreenRecorder`'s' `isRecording` to determine if we're currently recording. To stop a recording, you have to call the plainly named method `stopRecording`. This is only slight different from `startRecording`, in that it also returns to the callback an instance of `RPPreviewViewController`.

This `RPPreviewViewController` allows your users to scrub, edit and share their video recordings to the world. Or they can just save the recording to their photos, or discard it entirely.

If we want to know when the user is done interacting with the `RPPreviewViewController`, we'll have to assign ourselves as a delegate to the and extend the `RPPreviewViewControllerDelegate` protocol.

```
let recorder = RPScreenRecorder.shared()
if !recorder.isRecording {
  recorder.startRecording { (error) in
    guard error == nil else {
      print("Failed to start recording")
      return
    }

    self.recordButton.texture = SKTexture(imageNamed:"stop")
  }
} else {
  recorder.stopRecording(handler: { (previewController, error) in
    guard error == nil else {
      print("Failed to stop recording")
      return
    }

    previewController?.previewControllerDelegate = self
    self.viewController.present(previewController!, animated: true)

    self.recordButton.texture = SKTexture(imageNamed:"record")
  })
}
```

Here, we'll implement the `previewControllerDidFinish` method, and simply dismiss the controller, being sure to animate it, because... well, animations are fun!

```
extension GameScene: RPPreviewViewControllerDelegate {
	func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
		viewController.dismiss(animated: true)
	}
}
```

If you build and run, you can tap the record button. You'll first get a dialog asking if you want to give the app permission to record. This user consent prompt will be displayed every time you call `startRecording`, but once the user has accepted it, it will not be shown again for another eight minutes. Why 8? Your guess is as good as mine! In any case, your users now have control over what they'd like included in their recordings. When your done, tap the stop button, and you should see a new view controller gracefully slide into view. Feel free to playback your gameplay and share your wins with all your friends.

## Interlude 2

## Demo 3

## Closing
