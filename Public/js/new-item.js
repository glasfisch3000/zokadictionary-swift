let translations = document.getElementById("translations")
let references = document.getElementById("references")

let translationNumber = 0
let referenceNumber = 0

function addTranslation() {
	translationNumber += 1
	let number = translationNumber
	
	let section = document.createElement("section")
	section.id = `translation-section-${number}`
	section.classList.add("removable-section")
	translations.appendChild(section)
	
	let contents = document.createElement("div")
	section.appendChild(contents)
	
	let cancelButton = document.createElement("button")
	cancelButton.classList.add("symbol")
	cancelButton.textContent = "􀆄"
	cancelButton.setAttribute("onClick", `removeTranslation(${number})`)
	section.appendChild(cancelButton)
	
	
	let translationLabel = document.createElement("label")
	translationLabel.setAttribute("for", `translation-${number}`)
	translationLabel.textContent = "Translation"
	contents.appendChild(translationLabel)
	
	let translationInput = document.createElement("input")
	translationInput.classList.add("translation-input")
	translationInput.id = `translation-${number}`
	translationInput.setAttribute("type", "text")
	translationInput.setAttribute("placeholder", "Translation")
	translationInput.setAttribute("title", "Translation")
	translationInput.setAttribute("inputmode", "text")
	contents.appendChild(translationInput)
	
	
	let commentLabel = document.createElement("label")
	commentLabel.setAttribute("for", `translation-comment-${number}`)
	commentLabel.textContent = "Comment"
	contents.appendChild(commentLabel)
	
	let commentInput = document.createElement("input")
	commentInput.classList.add("translation-comment-input")
	commentInput.id = `translation-comment-${number}`
	commentInput.setAttribute("type", "text")
	commentInput.setAttribute("placeholder", "Comment")
	commentInput.setAttribute("title", "Comment")
	commentInput.setAttribute("inputmode", "text")
	contents.appendChild(commentInput)
}
