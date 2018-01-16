#NoEnv
SetBatchLines, -1


; --- Create a new chrome instance ---

FileCreateDir, ChromeProfile
ChromeInst := new Chrome("ChromeProfile")


; --- Connect to the active tab ---

Tab := ChromeInst.GetTab()


; --- Navigate to the pastebin ---

Tab.Call("Page.navigate", {"url": "https://p.ahkscript.org"})
Tab.WaitForLoad()


; --- Manipulation via DOM ---

; Find the root node
RootNode := Tab.Call("DOM.getDocument").root

; Find and change the name element
NameNode := Tab.Call("DOM.querySelector", {"nodeId": RootNode.nodeId, "selector": "input[name=name]"})
Tab.Call("DOM.setAttributeValue", {"nodeId": NameNode.NodeId, "name": "value", "value": "ChromeBot"})

; Find and change the description element
DescNode := Tab.Call("DOM.querySelector", {"nodeId": RootNode.nodeId, "selector": "input[name=desc]"})
Tab.Call("DOM.setAttributeValue", {"nodeId": DescNode.NodeId, "name": "value", "value": "Pasted with ChromeBot"})


; --- Manipulation via JavaScript ---

Tab.Evaluate("editor.setValue('test');")
Tab.Evaluate("document.querySelector('input[type=submit]').click();")
Tab.WaitForLoad()

MsgBox, % Tab.Evaluate("window.location.href").value

Tab.Call("Browser.close")
ExitApp
return


#include ../Chrome.ahk
