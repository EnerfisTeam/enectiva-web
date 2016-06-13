# Enectiva Web.
Enectiva web is using Hugo https://gohugo.io/. In this site, we can view how to use Hugo: https://gohugo.io/overview/usage/

Actually, we are using Hugo v0.15

Interesting command to use:

## How to start the server

We must to open command line
```Windows key``` -> Search **cmd** and press enter. If we have our web in the root of hard disk, we must to write into the black window

```
cd \
```

After, if our folder named `enectiva_web`
```
cd enectiva_web
```

To start the server, we must type
```
hugo server
```
To create a new post (We explain it bellow). If you can create a new post, please, close hugo server first.
```
hugo new
```

## Creating new blog post.

The command to do this is the next:

```
hugo new blog/XX/name-to-do.md
```

You must to change the "XX" to the languague what you can write the post (**CS**: Czech, **ES**: Spanish, **EN**: English, **IT**: Italian, **FR**: French, **DE**: German)

So if you want to create a new english post, yo need to write:

```
hugo new blog/en/the-price-of-energy-data.md
```


When you have your empty file, you must to go into the folder where you created the file.

- Open **Content** folder
- Open **blog** folder
- Open **en** folder
- Open your file, in this case **he-price-of-energy-data.md** with your favourite text editor (***Don't use Windows Notepad! the file will show broken***)
Important! You never must write the date in the filename


### How to use the header of file (archetype)

When you create a new post, automatically is created a file with a header. This header has the following labels by default:
```
---
author: Enerfis
cs/de/fr/es/it/en: blog
date: 2016-05-23T11:15:34+02:00
keywords:
- key
- words
schema: blog
slug: cs/de/fr/es/it/en
title: title of fil
---
```
In "cs/de/fr/es/it/en: blog" and "slug" we must to delete de label language that you dont use. So, if you want to create a new post in english:

```
---
author: Enerfis
en: blog
date: 2016-05-23T11:15:34+02:00
keywords:
- key
- words
schema: blog
slug: en
title: title of file
---
```
If you can add keywords, you can use it just like that

```
---
author: Enerfis
en: blog
date: 2016-05-23T11:15:34+02:00
keywords:
- enectiva
- energy
- monitoring
- meters
schema: blog
slug: en
title: title of file
---
```
## Generating files

To compile CoffeeScript, we need a linux packet. If you use a debian distribution, write.
```
sudo apt-get install CoffeeScript
```

### Gem to install

```
compass
cssminify
sass
uglifier
```

### Generate development

This command will to concatenate all JavaScript/Coffe and SASS files in only one file with a fingerprint to simplify de web calls. If you don't execute this command, you won't have CSS or JavaScript y the webpage

```
ruby generate.rb debug
```

### Generate production

This command will do the same than development and minify JavaScript and Css. **ONLY** when you generate production.
```
ruby generate.rb
```

## How to generate a file into root folder

If you have a file and you need it in root folder, you put the file in

```
static/
```

When Hugo generates the site, all files inside **static** will be render in public's root

## How to create a new section
You must to choose the language what you do create the new section and create the new item inside the folder.

```
/content/en/New_section/index.html
```
It's important to add in header of new file the label **schema**. With this label, we define wich will be the translation os the page.

When we are the new section created, we must to add wich are the translation for other languages

We must to open.
```
/data/pages.yml
```
The next text is an example how we write in the file
```
about:
  cs: o-enective
  en: about-enectiva
  fr: enectiva
  es: acerca-de-enectiva
  it: enectiva
  de: ueber-enectiva
```

**about** means the name of **schema** when we created the section.
```
  cs: o-enective
  en: about-enectiva
  fr: enectiva
  es: acerca-de-enectiva
  it: enectiva
  de: ueber-enectiva
```
This is the *URL* to translate the page.

If we want to add a new subsection, we need to write all relative url
```
solutionsschool:
  cs: reseni/verejne-budovy-skoly-knihovny
  en: solutions/schools-libraries-and-other-public-buildings
  fr: solutions/batiments-publics-ecoles-bibliotheques
  es: soluciones/escuelas-bibliotecas-y-otros-edificios-publicos
  it: soluzioni/scuole-biblioteche-e-altri-edifici-pubblici
  de: loesung/oeffentliche-gebaeude-schulen-bibliotheken
```
### Adding a new section into the menu

When we had the page created, we must to add into the menu. We have one file to define de menu and links.
```
/data/menu.yml
```

This file is betweened in four sections:

- **Top**: Is the menu under translation options
- **Footer**: Is the menu over footer
- **Features**: Is the menu to the *new* aspect of features page (en, fr, cs)
- **Solution**: Is the menu in the footer of subsections of solution.

If we want to add a new top item, we must to go to the correct language and add a new block.
```
  cs:
    about:
      Name: O Enectivě
      URL: /cs/o-enective
      Weight: 10

```
- **Cs** is the language
- **About** is a name for the section
- **Name** is the name to show in the menu
- **URL** is the absolut url
- **Weight** Is the order to show the menu (asc)

Hugo v0.15
