# References for API functions

## TemplateData

Library for processing [TemplateData](https://www.mediawiki.org/wiki/Help:TemplateData).

### mw.templatedata

Call syntax for a Root instance with a blessed reference to a proxy for TemplateData.

```lua
mw.templatedata( title, langCode )
```

- title – name of the page where a TemplateData element resides
- langCode – identificator for the language to use while processing the page

Returns a Root instance.

### mw.templatedata.load

Load a TemplateData object as a read-only proxied and cached table.

```lua
mw.templatedata.load( title, langCode )
```

- title – name of the page where a TemplateData element resides
- langCode – identificator for the language to use while processing the page

Returns a read-only table.

## Root

Instances holding a single blessed reference to a proxy for TemplateData.

### Root.bless

Bless an existing table into an instance

```lua
mw.templatedata.bless( t )
```

- t – table to be blessed

Returns a Root instance.

### Root:isValid