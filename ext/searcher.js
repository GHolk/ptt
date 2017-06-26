
function PttArticle(articleNode) {
    this.url = articleNode.getElementsByTagName('a')[0].href

    var titleText = articleNode.getElementsByTagName('h2')[0].textContent
    var matchTitle = titleText.match(/^\s*(Re:)?\s*(\[.*?\])?\s*(.*)/)
    if (matchTitle[1]) this.reply = true
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

var currentList = articleList

var queryForm = document.getElementById('query-form')

queryForm.onsubmit = function(evt) {
    evt.preventDefault()
    var evalStatement = this.elements['eval-condition'].value

    document.body.className = 'hide-article'
    currentList.forEach(function(article) { article.show(false) })
    currentList = currentList.filter(function(article, i, list) {
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
        return eval(evalStatement)
    })
    currentList.forEach(function(article) { article.show(true) })
    this.elements['match-number'].value = currentList.length
    document.body.className = 'show-article'
}

queryForm.elements['show-all'].onclick = function(evt) {
    evt.preventDefault()

    currentList = articleList
    currentList.forEach(function(article) { article.show(true) })
    this.form.elements['match-number'].value = currentList.length
}
