HomeKit is a library that allows users to use their Apple devices configure, communicate and control smart-home devices.

The HomeKit framework allows your apps to easily setup and control your HomeKit accessories. It provides a central store for the configuration these accessories in your home. Configuration is synchronized across all your apps and devices and is deeply integrated into iOS, WatchOS and tvOS.

HomeKit even provides you with a way to control accessories, or automation using Siri voice commands.

Before you learn how to control accessories from your app, its best to understand how Apple identifies pieces inside HomeKit.

At the root, HomeKit defines Homes, with one being designated as the "primary home". Every home needs to have a unique name, so when you ask Siri to interact with your home, it can easily identify if you mean your summer home, or your winter home. Unique names is a fixed requirement across each piece of HomeKit. Each home can have one or many rooms, and any one room can have one or many accessories. The idea of a unique name applies to both rooms and accessories.

Each accessory can be equipped with one or more services. Think of services as the capabilities of an accessory, like a ceiling fan with lights. In the case of the ceiling fan, it has two services, one for the fan, and one for the light. Finally, each service can have one or more of its own characteristics. A characteristic is a specific trait or value type associated with that service. So using our ceiling fan analogy, the fan service might have a speed characteristic. The light in the ceiling fan might have two characteristics, one for intensity and another for color.

The point is, devices can expose their characteristics, and developers can have granular control over how users interact with an accessory.

In this tutorial, we'll go over each of these pieces in an app that'll control the on/off state of a lightbulb.

Now, you may or may not have a HomeKit device available to you, however, in this tutorial, we'll make use of a simulator provided by Apple to create simulator HomeKit devices.

The easiest way to get the simulator is to open up the starter app, select the "LightSwitch" project in the Project Navigator, and selecting the "Capabilities" tab. In the list that appears, you should see an option for "HomeKit" with a toggle button set to "off". Enable it, and you should see a button with the text "Download HomeKit Simulator". Pressing the button will open a browser to your Apple Developer download page. Here, you'll have to search for "Hardware IO Tools for Xcode 7.3". Once you've found it, download it, and install. You will have to select the "HomeKit Accessory Simulator" app and move it into your Applications folder.

Once you've installed it, launch the simulator. In the left pane, you should see an empty list of Accessories. Clicking the "+" at the bottom of the list will prompt you with a dialog to create a new accessory. Give the accessory a name, and leave other fields blank. The first thing you'll note is that each device is given a unique "Setup Code". This code is used to pair and register a device when its on your network.

At the moment, your accessory has no service. Which is a sad existence for an accessory. Click the "Add Service..." button at the bottom of the page. In the dialog, you can see a dropdown selector next to Service. You can see that there are a number of "predefined" category of services that HomeKit lets you choose from, including a "Custom" category. Take a minute to go through them all, and when ready, select "Lightbulb". Feel free to give this service a name. You can see that the Lightbulb service, already comes with some predefined characteristics. You should see "On", "Brightness", "Hue" and "Saturation" as characteristics of the service. For the purposes of this demo, we can remove the last three characteristics and just focus on the "On" state of the characteristic. Congratulations, you've created your first HomeKit device!

Head back to the starter project.
