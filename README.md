# Lucee Admin Language Editor

A simple editor that helps adding new languages and translations to Lucee Administrator Extension by creating language XML resource files in the Administrator of the web-context (still in Beta).

## How to run

To run "Lucee Administrator Language Editor" locally you only need [CommandBox](https://www.ortussolutions.com/products/commandbox) as the only dependency. As soon as you have CommandBox installed and this repository downloaded/cloned to your local development machine and run **server.bat** (win) or **server.sh** (mac & linux).

## How the "Lucee Admin Language Editor" works

This are some of the functionalities that the Lucee Admin Language Editor gives:

- **Password and Password.txt Generation:** The "Lucee Administrator Language Editor" will generate a password and create the password.txt for you: When logging into the "Server Administrator" on the first time, just click on the "import" button. **Important:** You need to log into the "Server Administrator" first to make the "View in Server-/Web-Administrator"-Buttons work correctly.

- **Fast Viewing With "WYSIWYG":** After logging into the "Server-/Web-Administrator" you'll be able to save and push the created/edited languages files to the Lucee Administrator (click the "Save Changes & Push to Admin"-Button). Then you can load the files and view the changes by clicking the "View in Server-/Web-Administrator"-Buttons (you need to be logged into the "Server Administrator" first to make the "View in Server-/Web-Administrator"-Buttons work correctly).

- **Resource-File-Generation:** When saving a language, the editor takes the default English language resource file **en.xml** as the master/root file for generating/creating the corresponding resource file. The data is updated by RegEx-replacements. This ensures that comments, structure and sort order of the data is transported from the master file to the generating files.

- **Data XML-Encoding/Escaping**: The editor helps creating data and XML-escaping it correctly, following the [XML-Syntax](https://www.w3.org/TR/xml/#syntax) (see also [this stackoverflow post](https://stackoverflow.com/a/28152666/2645359)) . As an example, a string to display the following output to the user:

```html
Example:
<cfmail subject=sub from="#f#" to="#t#"/>
```

Needs an HTML-Code saved as follows:

```html
Example:&lt;br&gt;
&lt;cfmail subject=sub from="#f#" to="#t#"/&gt;
```

Because the HTML snippet above needs to be safely XML encoded/escaped, the editor saves the data as:

```html
<data key="some.example.property">Example:&amp;lt;br&amp;gt;
&amp;lt;cfmail subject=sub from="#f#" to="#t#"/&amp;gt;</data>
```

## About "Lucee Admin Language Editor"

I came up with the idea because I want to translate Lucee Administrator to Portuguese and Spanish to help my South American fellows (especially cf-brazil) to quickly dig and play around with Lucee Administrator in their own language.
