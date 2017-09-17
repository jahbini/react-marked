marked = require('marked')
React = require('react')
T=require 'teact'

module.exports.Marked = React.createClass(
  displayName: 'Marked'
  render: ->
    React.DOM.div { className: 'Marked' }, ReactParser.parse(marked.Lexer.lex(@props.markdown))
)
itemsRenderedCount = 0

extend = (o1, o2) ->
  Object.keys(o2).forEach (key) ->
    o1[key] = o2[key]
    return
  return

  
module.exports.TeactParser = class TeactParser
  constructor: ->
    @tokens = []
    @token = null
    @options = renderer: new ReactRenderer
    @renderer = @options.renderer
    return
  
  escape = (html, encode) ->
    html.replace(if !encode then /&(?!#?\w+;)/g else /&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace /'/g, '&#39;'
  
  unescape = (html) ->
    html.replace /&([#\w]+);/g, (_, n) ->
      n = n.toLowerCase()
      if n == 'colon'
        return ':'
      if n.charAt(0) == '#'
        return if n.charAt(1) == 'x' then String.fromCharCode(parseInt(n.substring(2), 16)) else String.fromCharCode(+n.substring(1))
      ''
  
  code: (code, lang, escaped) ->
    className = @props and @props.langPrefix
    React.DOM.pre { key: itemsRenderedCount++ }, React.DOM.code({ className: className }, code)
  blockquote: (quote) ->
    React.DOM.blockquote { key: itemsRenderedCount++ }, quote
  heading: (text, level, raw) ->
    React.DOM['h' + level] {
      key: itemsRenderedCount++
      id: raw.toLowerCase().replace(/[^\w]+/g, '-')
    }, text
  hr: ->
    React.DOM.hr key: itemsRenderedCount++
  br: ->
    React.DOM.br key: itemsRenderedCount++
  list: (body, ordered) ->
    if ordered
      return React.DOM.ol({ key: itemsRenderedCount++ }, body)
    React.DOM.ul { key: itemsRenderedCount++ }, body
  listitem: (text) ->
    React.DOM.li { key: itemsRenderedCount++ }, text
  paragraph: (text) ->
    React.DOM.p { key: itemsRenderedCount++ }, text
  table: (header, body) ->
    React.DOM.table { key: itemsRenderedCount++ }, React.DOM.thead(null, header), React.DOM.tbody(null, body)
  tablerow: (content) ->
    React.DOM.tr { key: itemsRenderedCount++ }, content
  strong: (content) ->
    React.DOM.strong { key: itemsRenderedCount++ }, content
  em: (content) ->
    React.DOM.em { key: itemsRenderedCount++ }, content
  codespan: (content) ->
    codespan { key: itemsRenderedCount++ }, content
  del: (content) ->
    React.DOM.del { key: itemsRenderedCount++ }, content
  link: (href, title, text) ->
    React.DOM.a {
      href: href
      title: title
      key: itemsRenderedCount++
    }, text
  image: (href, title, text) ->

    done = (e) ->
      e.preventDefault()
      console.log itemsRenderedCount
      false
  
    if !href
      return React.DOM.img(
        src: href
        title: title
        alt: text
        key: itemsRenderedCount++
        onDrop: done)
    React.DOM.img
      src: href
      title: title
      alt: text
      key: itemsRenderedCount++
  html: (html) ->
    React.DOM.div
      dangerouslySetInnerHTML: __html: html.join('')
      key: itemsRenderedCount++

  ReactParser.parse = (src) ->
    parser = new ReactParser
    parser.parse src
  
  parse: (src) ->
    out = []
    i = 0
    next = undefined
    @inline = new ReactInlineLexer(src.links, @options, @renderer)
    @tokens = src.reverse()
    while @next()
      out.push @tok()
    React.DOM.div null, out
  next: ->
    @token = @tokens.pop()
  peek: ->
    @tokens[@tokens.length - 1] or 0
  parseText: ->
    body = @token.text
    while @peek().type == 'text'
      body += '\n' + @next().text
    @inline.output body
  tok: ->
    `var bodyTemp`
      `var bodyTemp`
      `var bodyTemp`
    switch @token.type
      when 'space'
        return ''
        return
      when 'hr'
        return @renderer.hr()
        return
      when 'heading'
        return @renderer.heading(@inline.output(@token.text), @token.depth, @token.text)
        return
      when 'code'
        return @renderer.code(@token.text, @token.lang, @token.escaped)
        return
      when 'table'
        header = []
        body = []
        i = undefined
        row = undefined
        cell = undefined
        flags = undefined
        j = undefined
        # header
        cell = []
        i = 0
        while i < @token.header.length
          flags =
            header: true
            align: @token.align[i]
          cell.push @renderer.tablecell(@inline.output(@token.header[i]),
            header: true
            align: @token.align[i])
          i++
        header.push @renderer.tablerow(cell)
        i = 0
        while i < @token.cells.length
          row = @token.cells[i]
          cell = []
          j = 0
          while j < row.length
            cell.push @renderer.tablecell(@inline.output(row[j]),
              header: false
              align: @token.align[j])
            j++
          body.push @renderer.tablerow(cell)
          i++
        return @renderer.table(header, body)
        return
      when 'blockquote_start'
        bodyTemp = ''
        while @next().type != 'blockquote_end'
          bodyTemp += @tok()
        return @renderer.blockquote(bodyTemp)
        return
      when 'list_start'
        bodyTemp = []
        ordered = @token.ordered
        while @next().type != 'list_end'
          bodyTemp.push @tok()
        return @renderer.list(bodyTemp, ordered)
        return
      when 'list_item_start'
        bodyTemp = []
        while @next().type != 'list_item_end'
          bodyTemp.push if @token.type == 'text' then @parseText() else @tok()
        return @renderer.listitem(bodyTemp)
        return
      when 'loose_item_start'
        bodyTemp = []
        while @next().type != 'list_item_end'
          bodyTemp.push @tok()
        return @renderer.listitem(bodyTemp)
        return
      when 'html'
        html = if !@token.pre and !@options.pedantic then @inline.output(@token.text) else @token.text
        return @renderer.html(html)
        return
      when 'paragraph'
        return @renderer.paragraph(@inline.output(@token.text))
        return
      when 'text'
        return @renderer.paragraph(@parseText())
        return
    return
#class ReactInlineLexer
module.exports.ReactInlineLexer = class TeactInlineLexer extends marked.InlineLexer
# override the output fuction
  output: (src) ->
    out = []
    link = undefined
    text = undefined
    href = undefined
    cap = undefined
    while src
      # escape
      if cap = @rules.escape.exec(src)
        src = src.substring(cap[0].length)
        out.push cap[1]
        j++
        continue
      # autolink
      if cap = @rules.autolink.exec(src)
        src = src.substring(cap[0].length)
        if cap[2] == '@'
          text = if cap[1].charAt(6) == ':' then @mangle(cap[1].substring(7)) else @mangle(cap[1])
          href = @mangle('mailto:') + text
        else
          text = escape(cap[1])
          href = text
        out.push @renderer.link(href, null, text)
        j++
        continue
      # url (gfm)
      if !@inLink and (cap = @rules.url.exec(src))
        src = src.substring(cap[0].length)
        text = escape(cap[1])
        href = text
        out.push @renderer.link(href, null, text)
        j++
        continue
      # tag
      if cap = @rules.tag.exec(src)
        if !@inLink and /^<a /i.test(cap[0])
          @inLink = true
        else if @inLink and /^<\/a>/i.test(cap[0])
          @inLink = false
        src = src.substring(cap[0].length)
        out.push if @options.sanitize then escape(cap[0]) else cap[0]
        j++
        continue
      # link
      if cap = @rules.link.exec(src)
        src = src.substring(cap[0].length)
        @inLink = true
        out.push @outputLink(cap,
          href: cap[2]
          title: cap[3])
        @inLink = false
        j++
        continue
      # reflink, nolink
      if (cap = @rules.reflink.exec(src)) or (cap = @rules.nolink.exec(src))
        src = src.substring(cap[0].length)
        link = (cap[2] or cap[1]).replace(/\s+/g, ' ')
        link = @links[link.toLowerCase()]
        if !link or !link.href
          out.push cap[0].charAt(0)
          src = cap[0].substring(1) + src
          j++
          continue
        @inLink = true
        out.push @outputLink(cap, link)
        @inLink = false
        j++
        continue
      # strong
      if cap = @rules.strong.exec(src)
        src = src.substring(cap[0].length)
        out.push @renderer.strong(@output(cap[2] or cap[1]))
        j++
        continue
      # em
      if cap = @rules.em.exec(src)
        src = src.substring(cap[0].length)
        out.push @renderer.em(@output(cap[2] or cap[1]))
        j++
        continue
      # code
      if cap = @rules.code.exec(src)
        src = src.substring(cap[0].length)
        out.push @renderer.codespan(escape(cap[2], true))
        j++
        continue
      # br
      if cap = @rules.br.exec(src)
        src = src.substring(cap[0].length)
        out.push @renderer.br()
        j++
        continue
      # del (gfm)
      if cap = @rules.del.exec(src)
        src = src.substring(cap[0].length)
        out.push @renderer.del(@output(cap[1]))
        j++
        continue
      # text
      if cap = @rules.text.exec(src)
        src = src.substring(cap[0].length)
        out.push escape(@smartypants(cap[0]))
        j++
        continue
      if src
        throw new Error('Infinite loop on byte: ' + src.charCodeAt(0))
    out

module.exports = Marked
