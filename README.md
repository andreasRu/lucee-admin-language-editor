# Lucee Admin Language Editor

A simple editor that helps adding new languages and translations to Lucee 6.0 Administrator Extension by creating language JSON resource files in the Administrator. An online version is available at [https://lucee-lang-editor.rhein-berg-digital.de/](https://lucee-lang-editor.rhein-berg-digital.de/).

## How to run

To run "Lucee Administrator Language Editor" locally you only need [CommandBox](https://www.ortussolutions.com/products/commandbox) as the only dependency. As soon as you have CommandBox installed and this repository downloaded/cloned to your local development machine and run **server.bat** (win) or **server.sh** (mac & linux).

## How the "Lucee Admin Language Editor" works

These are some of the main functionalities that the Lucee Admin Language Editor offers:

- **Password and Password.txt Generation when running locally:** The "Lucee Administrator Language Editor" will generate a password and create the password.txt for you: When logging into the "Server Administrator" on the first time, just click on the "import" button.

- **Add new text properties:** You can now add new porperties to your JSON language file. The Editor will check and prevent from adding any new conflicting properties.

- **Fast Viewing With "WYSIWYG" when running locally:** After logging into the "Server-/Web-Administrator" you'll be able to save and push the created/edited languages files to the Lucee Administrator (click the "Save Changes & Push to Admin"-Button). Then you can load the files and view the changes by clicking the "View in Server-/Web-Administrator"-Buttons (you need to be logged into the "Server Administrator" first to make the "View in Server-/Web-Administrator"-Buttons work correctly).

- **ChatGPT Prompt creation:** You may find this helpful for translating JSON blocks with ChatGPT. The button will get a full JSON copy of the top parent key and create a ChatGPT-Prompt for a much quicker translation. Then you can copy the top JSON property to the JSON editor. At this moment human translation is (still) the best.

- **Plugin-Extension**: This repository also offers a LanguagePack-Plugin(beta) with a language switch functionality located at `/extension`. At the moment this plugin is just for testing purpose. If you want to test it, you can download the latest [LanguagePack-Extension here](https://github.com/andreasRu/lucee-admin-language-editor/raw/master/extension/F1A3EEAF-5B7A-499C-9656DE3E103C8EA9.lex) or you can try your own language: Simply unzip the downloaded extension and paste your language JSON to yourself: `\extension\plugins\languagepack\language` directory and ZIP the content of extension directory again and rename it to `F1A3EEAF-5B7A-499C-9656DE3E103C8EA9.lex`. Then you can try it as an extension to your own Lucee6 Administrator.

## About "Lucee Admin Language Editor"

I came up with the idea because I want to translate Lucee Administrator to Portuguese and Spanish to help my South American fellows (especially cf-brazil) to quickly dig and play around with Lucee Administrator in their own language. Also, as I contribute to the Lucee Administrator myself, I find this editor much quicker adding properties and translations to source code.
