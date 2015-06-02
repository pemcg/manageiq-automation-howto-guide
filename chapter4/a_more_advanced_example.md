## A More Advanced Example

In this example we'll create an automate method that adds a custom attribute to a VM. We'll launch the automation instance from a button, and we'll include a dialog to prompt for the text to add.

### Creating the Service Dialog
The first thing we must do is create a _Service Dialog_ to be displayed when our custom button is clicked.

Navigate to _Automation -> Customization_, select _Service Dialogs_ in the accordion, highlight _All Dialogs_, then select _Configuration -> Add a new Dialog_ (don't click the _Add_ button yet...)

![Screenshot](images/screenshot24.png)

Give the button a Label and Description of _Button_, check the Submit and Cancel options, and click _+ -> Add a new Tab to this Dialog_ (don't click the _Add_ button yet...)

![Screenshot](images/screenshot25.png)

Give the tab a Label and Description of _Main_, check the Submit and Cancel options, and click _+ -> Add a new Box to this Dialog_ (don't click the _Add_ button yet...)

![Screenshot](images/screenshot26.png)

Give the box a Label and Description of _Custom Attribute_, check the Submit and Cancel options, and click _+ -> Add a new Element to this Box_ (don't click the _Add_ button yet...)

![Screenshot](images/screenshot27.png)

Give the new Element the Label of _Key_, the Name of _key_, and a Type of _Text Box_. Leave the other values as default (don't click the _Add_ button yet...)

![Screenshot](images/screenshot28.png)

Click _+ -> Add a new Element to this Box_ to create a second element with the Label of _Value_, the Name of _value_, and a Type of _Text Box_. Leave the other values as default, and now, finally click the _Add_ button.

![Screenshot](images/screenshot29.png)

### Creating the Instance and Method

Create a new Instance in our _Methods_ class, called _AddCustomAttribute_. Leave the _password_, _servername_ and _username_ schema fields blank, but add the value _add\_custom\_attribute_ in the _execute_ field.

Create a new Method in our _Methods_ class, called _add\_custom\_attribute_. Paste the following into the _Data_ box:

```ruby
$evm.log(:info, "add_custom_attribute started")
#
# Get the VM object
#
vm = $evm.root['vm']
#
# Get the dialog values
#
key = $evm.root['dialog_key']
value = $evm.root['dialog_value']
#
# Set the custom attribute
#
vm.custom_set(key, value)
exit MIQ_OK
```

### Creating the Button
Navigate to _Automation -> Customization_, select _Buttons_ in the accordion, highlight _Object Types -> VM and Instance_, then select _Configuration -> Add a new Button Group_

![Screenshot](images/screenshot30.png)

Create a Button Group called _Tutorial_, select a Button Group Image 

![Screenshot](images/screenshot31.png)

Click the _Add_ button. Now highlight this new _Tutorial_ button group in the accordion, and select _Configuration -> Add a new Button_

![Screenshot](images/screenshot32.png)

Specify a Button and Hover Text of _Add Custom Attribute_, select a suitable button image, and pick our new _Button_ Dialog from the drop-down list.

![Screenshot](images/screenshot33.png)

We'll call our instance from the button in the same way that we did from Simulation, by making a System/Process/Request call to _Call\_Instance_ with the key/value pairs:

```
namespace -> Tutorial/General
class -> Methods
instance -> AddCustomAttribute
```
### Running the Instance
If we navigate to a VM and drill down into the details, we should see our new button group and button:

![Screenshot](images/screenshot34.png)

If we click on the _Add Custom Attribute_ button we should be presented with our dialog:

![Screenshot](images/screenshot35.png)

Enter some text and click _Submit_, wait a few seconds, and we should see the new custom attribute displayed at the botton of the VM details pane:

![Screenshot](images/screenshot36.png)
