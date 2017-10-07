Convert Markdown into HTML, securely
====================================

This program accepts your input as a series of netstrings,
that is, an ASCII byte count followed by a colon followed by a string.
Null bytes are not special (though, as per the CommonMark spec, they get replaced by U+FFFD).
You do not have to perform any escaping; that's why we use netstrings as our preferred framing protocol.

like this:

    44:http://github.com/notriddle/rundown/issues/130:*This* is a basic [example](/)

An input is a base URL followed by a Markdown document,
in this case, the URL is `http://github.com/notriddle/rundown/issues/1`
and the document is `*This* is a basic [example](/)`.

Relative URLs will be resolved, allowing you to embed the HTML anywhere
while still having the URLs resolve correctly.

The response will also be a netstring:

    39:<p><em>This</em> is a basic example</p>
