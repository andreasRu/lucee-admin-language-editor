# Lucee Admin Language Editor

A simple editor that helps adding new languages and translations to Lucee Administrator Extension by creating language XML resource files in the Administrator of the web-context (still in Beta).

## How to run

To run "Lucee Administrator Language Editor" locally you only need [CommandBox](https://www.ortussolutions.com/products/commandbox) as the only dependency. As soon as you have CommandBox installed and this repository downloaded/cloned to your local development machine and run **server.bat** (win) or **server.sh** (mac & linux).

**Limitations**: At the moment the Editor works on Lucee Version 5.3. You may use it with Lucee Snapshots 6.0, but only in "multi"-Mode, because the resource file location in Lucee 6.0 "single" mode differs.

## How the "Lucee Admin Language Editor" works

This are some of the main functionalities that the Lucee Admin Language Editor offers:

- **Password and Password.txt Generation:** The "Lucee Administrator Language Editor" will generate a password and create the password.txt for you: When logging into the "Server Administrator" on the first time, just click on the "import" button. 

- **Fast Viewing With "WYSIWYG":** After logging into the "Server-/Web-Administrator" you'll be able to save and push the created/edited languages files to the Lucee Administrator (click the "Save Changes & Push to Admin"-Button). Then you can load the files and view the changes by clicking the "View in Server-/Web-Administrator"-Buttons (you need to be logged into the "Server Administrator" first to make the "View in Server-/Web-Administrator"-Buttons work correctly).

- **Resource-File-Generation:** When saving a language, the editor takes the default English language resource file **en.xml** as the master/root file for generating/creating the corresponding resource file. The data is updated by RegEx-replacements. This ensures that comments, structure and sort order of the data is transported from the master file to the generating files. That way Lucee Core Devs can focus on the en.xml file as beeing treated as the **master parent file** for the other language files.

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

- **Plugin-Extension**: This repository also offers a LanguagePack-Plugin with a language switch functionality located at `/extension`. At the moment this plugin is just for testing purpose. If you want to test it with your own language, just add it the created XML file to `\extension\webcontexts\admin\resources\language\` directory and ZIP the extension directory and rename it to `F1A3EEAF-5B7A-499C-9656DE3E103C8EA9.lex`. Then you can add it as a plugin.

## About "Lucee Admin Language Editor"

I came up with the idea because I want to translate Lucee Administrator to Portuguese and Spanish to help my South American fellows (especially cf-brazil) to quickly dig and play around with Lucee Administrator in their own language.
