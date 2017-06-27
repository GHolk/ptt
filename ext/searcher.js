
function PttArticle(articleNode) {
    this.url = articleNode.getElementsByTagName('a')[0].href

    var titleText = articleNode.getElementsByTagName('h2')[0].textContent
    var matchTitle = titleText.match(/^\s*(.{1,5}:)?\s*(\[.*?\])?\s*(.*)/)
    if (matchTitle[1]) this.reply = matchTitle[1].slice(0,-1)
    if (matchTitle[2]) this.category = matchTitle[2].slice(1,-1)
    if (matchTitle[3]) this.title = matchTitle[3]

    var usernameNode = articleNode.getElementsByTagName('u')[0]
    var usernameText = usernameNode.textContent
    var matchUser
    if (matchUser = usernameText.match(/(\w*)\s*(\(.*\))?/)) {
        if (matchUser[1]) this.username = matchUser[1]
        if (matchUser[2]) this.nickname = matchUser[2].slice(1,-1)
    }

    var boardAndDate = usernameNode.nextSibling.textContent
    var matchBoardDate
    if (matchBoardDate = boardAndDate.match(/(\w+?)\s*@\s*(.*)/)) {
        this.board = matchBoardDate[1]
        this.date = new Date(matchBoardDate[2])
    }

    this.description =
        articleNode.getElementsByTagName('pre')[0].textContent
    this.raw = articleNode.textContent
    this.node = articleNode
}

PttArticle.prototype.reply = false
PttArticle.prototype.category = ''
PttArticle.prototype.title = ''
PttArticle.prototype.username = ''
PttArticle.prototype.nickname = ''
PttArticle.prototype.board = ''
PttArticle.prototype.description = ''
PttArticle.prototype.date = new Date('')
PttArticle.prototype.node = null

PttArticle.prototype.show = function(toShow) {
    if (toShow === true) this.node.className = 'show-article'
    else if (toShow == false) this.node.className = 'hide-article'
    else return this.node.className != 'hide-article'
}

var divs = document.getElementsByTagName('div')
var articleList = []
for (var i=0; i<divs.length; i++) {
    articleList.push(new PttArticle(divs[i]))
}

var queryForm = document.getElementById('query-form')

queryForm.onsubmit = function(evt) {
    evt.preventDefault()
    evalQueryAndPushState(this.elements['eval-condition'].value)
}

function evalQueryAndPushState(queryStatement) {
    var list = evalQuery(queryStatement)
    showWithIndexList(list)
    pushQueryState(queryStatement, list)
}

function evalQuery(queryStatement) {
    var queryFunction = queryStatementToFunction(queryStatement)

    var showNoError
    return articleList.map(
    function mapTest(article, i, list){
        try {
            return queryFunction(article, i, list)
        }
        catch (evalError) {
            if (!showNoError) showNoError = confirm(
                'eval query error:\n\t' +
                evalError + '\n' +
                'skip all errors?'
            )
            console.log(evalError)
            return false
        }
    })
}

function pushQueryState(queryStatement, list) {
    history.pushState(
        list,
        'eval ' + queryStatement,
        '?query-statement=' + encodeURIComponent(queryStatement)
    )
}

window.onpopstate = function whenPopState(evt) {
    var state = evt.state
    if (Array.isArray(state)) showWithIndexList(state)
}

function queryStatementToFunction(queryStatement) {
    return function evalQuery(article, i, list) {
        var raw = article.raw
        var reply = article.reply 
        var category = article.category 
        var title = article.title 
        var username = article.username 
        var nickname = article.nickname 
        var board = article.board 
        var description = article.description 
        var date = article.date 
        var node = article.node 

        return eval(queryStatement)
    }
}


var matchCountNode = queryForm.elements['match-number']

function showWithIndexList(indexList) {
    document.body.className = 'hide-article'

    var matchCount = 0
    for (var i=0, l=indexList.length; i<l; i++) {
        if (indexList[i]) {
            articleList[i].show(true)
            matchCount++
        }
        else {
            articleList[i].show(false)
        }
    }

    matchCountNode.value = matchCount
    document.body.className = 'show-article'
}

// init query
if (location.search.match(/^\?query-statement/)) {
    evalQueryAndPushState(decodeURIComponent(location.search.slice(17)))
}
else {
    history.pushState(
        articleList.map(function(){return true}),
        null, ''
    )
}
