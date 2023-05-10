# react-quill image upload

|                 |                           |
| --------------: | ------------------------- |
| _Conducted by:_ | Katie Prochilo            |
|  _Sprint Name:_ | Integration Test and Docs |
|         _Date:_ | 5 October 2021            |

## Overview

The hearing details include a rich text box to send an email message to participants. The text box uses the library
[react-quill](https://www.npmjs.com/package/react-quill), which allows for out-of-the-box formatting including bulleted
lists, bold text, italicized text, font sizes, and more. However, react-quill does not include image uploads, which are
needed by the courts to send official and professional emails to participants.

## Goals

- Upload images in the rich text box within hearing details.
- An extensible solution would be nice in case other tools are desired (embedding, videos, iFrames, etc.).
- Any additional image features would be great:
  - Resizing, justifying, drag-and-drop placement and positioning
- Continue to accurately validate if the rich text box is empty.

## Additional validation

The rich text is processed as HTML that must be validated to insure it's not empty. However, even when the text box
appears empty there are actually empty HTML tags such as `<h1><br></h1>`, so it's not possible to simply check for empty
strings during validation. Instead, we must check that the HTML tags do not contain content.

The function `isEmptyHtml(str: string): boolean` handles this currently, but the validation for the rich text box will
need to be updated to support text-less `<img>` tags. Please note that this code hasn't been tested extensively, but is
close to what will be needed once there is image upload support:

```typescript
export function isEmptyHtml(str: string): boolean {
  const quillEditor = document.getElementsByClassName("ql-editor")[0];
  const children = quillEditor!.childNodes;

  if (children.length > 0) {
    // This list can be updated as custom modules are added that support more text-less features. For example, ["EMBED",
    // "IFRAME", "IMG", "PICTURE", "VIDEO"]
    const allowedEmptyTags = ["IMG"];

    // Note: This for loop is not necessary if you only plan to work with <img> text-less tags.
    for (let i = 0; i < children.length; i += 1) {
      if (
        allowedEmptyTags.includes((children[i] as unknown as Node).nodeName)
      ) {
        return false;
      }
    }
  }

  // Below is the current/original body of isEmptyHtml():
  const parser = new DOMParser();
  const doc = parser.parseFromString(str, "text/html");
  return doc.body.textContent?.trim() === "";
}
```

Tests should be added for scenarios when the rich text box is empty, and the last toolbar option that the user selected
was the image upload.

## Quill toolbar module

Quill contains a [toolbar module](https://quilljs.com/docs/modules/toolbar/#toolbar-module) that can be configured with
custom containers and handlers. A custom toolbar module will add an icon to the formatting menu that matches the
react-quill styling. The Quill website has an [example of image uploads](https://quilljs.com/docs/formats/), and the GIF
below demonstrates how this will look and work with the current email message:

![Demo of image uploads with react-quill toolbar
modules](../../images/docs-trade-studies-react-quill-image-upload-demo.gif)

### Pros

- Recommended in react-quill documentation.
- Can left, center, or right-justify the images.
- Can drag and drop images to a new line.
- Containers require minimal code updates:

  - To get a toolbar icon, add a string array as a prop to the `ReactQuill` component.

```typescript
    modules={
    { 
      toolbar: {
        container: [
          ['link', 'image'],
          ['clean'],
          [{ 'color': [] }]
        ],
        handlers: {
          image: this.imageHandler
        }
      },
      table: true 
    }
   } 
```

- Custom HTML containers are available:
  - Should not be necessary for images.
  - Allow elements that are not directly supported by react-quill.
  - Can have functionality completely separate of Quill.

### Cons out of the box

- Cannot freely position the images.
- Cannot resize images.
  - [GitHub issue](https://github.com/zenoamaro/react-quill/issues/197) that covers how to add image resizing
    functionality.
