
Sub init()

    m.UriHandler = createObject("roSGNode","Search UrlHandler")
    m.UriHandler.observeField("searchResult","handleGetSearch")
    m.miniKeyboard = m.top.findNode("miniKeyboard")
    m.searchBtn = m.top.findNode("searchBtn")
    
    m.searchBtn.observeField("buttonSelected","doGetSearch")

    'Load common variables
    loadCommon()
    
    ' Load in the OAuth Registry entries
    loadReg()
    
    'Set some UI customizations
    m.miniKeyboard.texteditbox.maxTextLength    = 20
    m.miniKeyboard.texteditbox.hintText         = "Google Photos Search"
    m.miniKeyboard.texteditbox.hintTextColor    = "#949596"
    m.miniKeyboard.texteditbox.textColor        = "#313233"
    
End Sub


' URL Request to fetch search
Sub doGetSearch()
    print "Search.brs [doGetSearch]"
    keyword = m.miniKeyboard.textEditBox.text
    
    if keyword <> ""
        signedHeader = oauth_sign(m.global.selectedUser)
        makeRequest(signedHeader, m.gp_prefix + "?kind=photo&v=3.0&q="+keyword+"&max-results=1000&thumbsize=220&imgmax="+getResolution(), "GET", "", 0)
    end if
End Sub


Sub doRefreshToken()
    print "Albums.brs [doRefreshToken]"

    params = "client_id="                  + m.clientId
    params = params + "&client_secret="    + m.clientSecret
    params = params + "&refresh_token="    + m.refreshToken[m.global.selectedUser]
    params = params + "&grant_type="       + "refresh_token"

    makeRequest({}, m.oauth_prefix+"/token", "POST", params, 2)
End Sub


Sub handleGetSearch(event as object)
    print "Search.brs [handleGetSearch]"

    response = event.getData()
    if response.code <> 200 then
        doRefreshToken()
    else

        rsp=ParseXML(response.content)
        'if rsp=invalid then
        '    ShowErrorDialog("Unable to parse Google Photos API response" + LF + LF + "Exit the channel then try again later","API Error")
        'end if
        
        m.screenActive = createObject("roSGNode", "My Albums")
        m.screenActive.imageContent = response
        m.screenActive.loaded = true
        m.top.appendChild(m.screenActive)
        m.screenActive.setFocus(true)
        
        m.miniKeyboard.visible = false
        
    end if

End Sub


Function onKeyEvent(key as String, press as Boolean) as Boolean
    if press then
        print "KEY: "; key
        if (key = "down") and (m.miniKeyboard<>invalid) and (m.miniKeyboard.focusedChild.id = "")
            m.searchBtn.setFocus(true)
            return true
        else if (key = "up") and (m.miniKeyboard<>invalid) and (m.miniKeyboard.focusedChild.id = "searchBtn")
            m.miniKeyboard.setFocus(true)
            return true
        else if (key = "options")
            doGetSearch()
            return true        
        end if
    end if

    'If nothing above is true, we'll fall back to the previous screen.
    return false
End Function