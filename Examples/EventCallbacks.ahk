#NoEnv
SetBatchLines, -1

#Include ../Chrome.ahk

TestPages := 3

; --- Define a data URL for the test page ---

; https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs
DataURL =
( Comments
data:Text/html, ; This line makes it a URL
<!DOCTYPE html>
<html>
	<head>
		; Use {} to allow text insertion using Format() later
		<title>Test Page {}</title>
	</head>
	<body>
		<button class="someclass">Click Me!</button>
    <br/>
    <br/>
		<button class="someotherclass">Exit App</button>
	</body>
</html>
)


; --- Define some JavaScript to be injected into each page ---

JS =
(
document.querySelector("button.someclass").onclick = function() {
	this.counter = this.counter == null ? this.counter = 1 : this.counter+1;
	console.log("AHK:" + this.counter);
}

document.querySelector("button.someotherclass").onclick = function(){
  console.log("AHK:ExitApp");
}
)


; --- Create a new Chrome instance ---

; Define an array of pages to open
DataURLs := []
Loop, %TestPages%
	DataURLs.Push(Format(DataURL, A_Index))

; Open Chrome with those pages
FileCreateDir, ChromeProfile
ChromeInst := new Chrome("ChromeProfile", DataURLs)


; --- Connect to the pages ---

PageInstances := []
Loop, %TestPages%
{
	WinWait, Test Page 1 - Google Chrome
	; Bind the page number to the function for extra information in the callback
	BoundCallback := Func("Callback").Bind(A_Index, ChromeInst, PageInst)
	
	; Get an instance of the page, passing in the callback function
	if !(PageInst := ChromeInst.GetPageByTitle(A_Index, "contains",, BoundCallback))
	{
		MsgBox, Could not retrieve page %A_Index%!
		ChromeInst.Kill()
		ExitApp
	}
	PageInstances.Push(PageInst)
	
	; Enable console events and inject the JS payload
	PageInst.WaitForLoad()
	PageInst.Call("Console.enable")
	PageInst.Evaluate(JS)
}

Return


Callback(PageNum, ChromeInst, PageInst, Event)
{
	; Filter for console messages starting with "AHK:"
	if (Event.Method == "Console.messageAdded"
		&& InStr(Event.params.message.text, "AHK:") == 1)
	{
		; Strip out the leading AHK:
		Text := SubStr(Event.params.message.text, 5)
		If (Text == "ExitApp"){
      			ChromeInst.Kill()
			for Index, PageInst in PageInstances
				PageInst.Disconnect()
      			ExitApp
    		}
		ToolTip, Clicked %Text% times on page %PageNum%
	}
}
