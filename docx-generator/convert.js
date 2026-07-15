const fs = require('fs');
const marked = require('marked');
const HTMLToDOCX = require('html-to-docx');

async function convert() {
    const mdContent = fs.readFileSync('../Client Functions Specification - Camera Store.md', 'utf-8');
    const htmlString = marked.parse(mdContent);
    const docxBuffer = await HTMLToDOCX(htmlString, null, {
        table: { row: { cantSplit: true } },
        footer: true,
        pageNumber: true,
    });
    fs.writeFileSync('../Client Functions Specification - Camera Store (Updated).docx', docxBuffer);
    console.log('Successfully generated DOCX file!');
}

convert().catch(console.error);
