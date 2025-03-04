## Roles v Inheritance

A great way of composing behaviour

Show how to add a Role to Restrictionmap.pm

Use Type validation to make sure that `_graphictype` is one of text, jpg or png
`enum 'FORMAT', [qw( text jpg png jpeg )];`

Use requires to make sure that the using class can do everything it needs to

## graphics methods in DrawGraphics.pm

`_drawmap_png` and `_drawmap_jpg` are identical methods
except the final GD method call at the end. this violates
the DRY principle (don't repeat yourself)

Use a dispatch table instead

create a drawmap_graphics method that takes the format as an argument
and whatever is used as the `_drawmap_text` method.
Perhaps this is a good place to show off fluent programming so that
the output of $self->_drawmap_text is the input to $self->_drawmap_graphics
like
```
$self->_drawmap_text->_drawmap_graphics
```

Explain p283 where it says how to export the html header Content-type
to image/png and image/jpeg in Mojo
