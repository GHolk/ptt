
const fs = require('fs')
const cheerio = require('cheerio')

const baseUrl = 'http://gholk.github.io/ptt'
const cheerioOption = {
    decodeEntities: false
}

function promiseRead(path) {
    return new Promise((promiseDone, promiseError) => {
        fs.readFile(path, 'utf8', (readError, fileString) => {
            if (readError) promiseError(readError)
            else promiseDone(fileString)
        })
    })
}

function parseMeta($) {
    const meta = {}
    meta.file = $('link[rel=canonical]').attr('href').match(/[^\/]*$/)[0]
    meta.title = $('meta[property="og:title"]').attr('content')
    meta.description = $('meta[property="og:description"]').attr('content')
    meta.content = $('#main-content').html()
    $('.article-meta-tag').each((i, el) => {
        const $tag = $(el)
        const $value = $tag.next()
        switch ($tag.text()) {
        case '作者':
            const userString = $value.text()
            const scanUser = userString.match(/^(\w+) \((.*)\)$/)
            meta.username = scanUser[1]
            meta.email = scanUser[1] + '.bbs@ptt.cc'
            meta.nickname = scanUser[2]
            break
        case '看板':
            meta.board = $value.text()
            break
        case '時間':
            meta.date = $value.text()
            break
        }
    })
    return meta
}

function printMeta(meta) {
    const m = {}
    for (const key in meta) m[key] = escape(meta[key])
    const url = baseUrl + m.file
    console.log('%s', `<entry>
<id>${url}</id>
<title>${m.title}</title>
<link rel="alternate" href="${baseUrl}/${m.file}" />
<published>${m.date}</published>
<category term="${m.board}" />

<author>
<name>${m.nickname}</name>
<email>${m.email}</email>
</author>

<summary>${m.description}</summary>
<content type="html">${m.content}</content>
</entry>`)
}
            

function generateEntry(path) {
    return promiseRead(path)
        .then((htmlString) => cheerio.load(htmlString, cheerioOption))
        .then(parseMeta)
        .then(printMeta)
        .catch((metaError) => {
            console.error(path)
            console.error(metaError)
        })
}

function escape(html) {
    return html
        .replace(/\&/g, '&amp;')
        .replace(/>/g, '&gt;')
        .replace(/</g, '&lt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;')
}

for (const path of process.argv) {
    const pttRegexp = /^M\..*\.html$/
        if (pttRegexp.test(path)) {
            generateEntry(path)
        }
}
