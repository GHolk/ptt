
function PttArticle(titleNode, smallNode, descriptionNode) {
    this.titleNode = titleNode

    var matchTitle = title.match(/^\s*(Re:)?\s*(\[.*?\])?\s*(.*)/)
    if (matchTitle[1]) this.reply = true
    if (matchTitle[2]) this.category = matchTitle[2].slice(1,-1)
    if (matchTitle[3]) this.title = matchTitle[3]

    var splitSmall = small.split(/@/g)
    if (splitSmall[0]) {
        var matchUser = splitSmall[0].match(/(\w*)\s*(\(.*\))/)
        this.username = matchUser[1]
        this.nickname = matchUser[2].slice(1,-1)
    }
    if (splitSmall[1]) this.board = splitSmall[1]
    if (splitSmall[2]) this.date = new Date(splitSmall[2])
}

PttArticle.prototype.reply = false
PttArticle.prototype.category = ''
PttArticle.prototype.title = ''
PttArticle.prototype.username = ''
PttArticle.prototype.nickname = ''
PttArticle.prototype.board = ''
PttArticle.prototype.date = new Date('')



