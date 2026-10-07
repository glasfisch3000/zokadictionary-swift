let translationNumber = 0
let referenceNumber = 0

let wordFetchTask = null
let allWords = []

function addTranslation() {
	let translations = document.getElementById("translations")
	
	translationNumber += 1
	let number = translationNumber
	
	let section = document.createElement("section")
	section.id = `translation-${number}`
	section.classList.add("removable-section")
	translations.appendChild(section)
	
	let contents = document.createElement("div")
	section.appendChild(contents)
	
	let cancelButton = document.createElement("button")
	cancelButton.classList.add("symbol")
	cancelButton.classList.add("small-button")
	cancelButton.classList.add("destructive")
	cancelButton.textContent = "􀆄"
	cancelButton.setAttribute("onClick", `removeTranslation(${number})`)
	cancelButton.setAttribute("type", "button")
	section.appendChild(cancelButton)
	
	
	let translationLabel = document.createElement("label")
	translationLabel.setAttribute("for", `translation-${number}-value`)
	translationLabel.textContent = "Translation"
	contents.appendChild(translationLabel)
	
	let translationInput = document.createElement("input")
	translationInput.classList.add("translation-input")
	translationInput.id = `translation-${number}-value`
	translationInput.setAttribute("type", "text")
	translationInput.setAttribute("placeholder", "Translation")
	translationInput.setAttribute("title", "Translation")
	translationInput.setAttribute("inputmode", "text")
	translationInput.required = true
	contents.appendChild(translationInput)
	translationInput.focus()
	
	
	let commentLabel = document.createElement("label")
	commentLabel.setAttribute("for", `translation-${number}-comment`)
	commentLabel.textContent = "Comment"
	contents.appendChild(commentLabel)
	
	let commentInput = document.createElement("input")
	commentInput.classList.add("translation-comment-input")
	commentInput.id = `translation-${number}-comment`
	commentInput.setAttribute("type", "text")
	commentInput.setAttribute("placeholder", "Comment")
	commentInput.setAttribute("title", "Comment")
	commentInput.setAttribute("inputmode", "text")
	contents.appendChild(commentInput)
}

function removeTranslation(number) {
	let section = document.getElementById(`translation-${number}`)
	section.remove()
}


function addReference() {
	let references = document.getElementById("references")
	
	referenceNumber += 1
	let number = referenceNumber
	
	let section = document.createElement("section")
	section.id = `reference-${number}`
	section.classList.add("removable-section")
	references.appendChild(section)
	
	let contents = document.createElement("div")
	section.appendChild(contents)
	
	let cancelButton = document.createElement("button")
	cancelButton.classList.add("symbol")
	cancelButton.classList.add("small-button")
	cancelButton.classList.add("destructive")
	cancelButton.textContent = "􀆄"
	cancelButton.setAttribute("onClick", `removeReference(${number})`)
	cancelButton.setAttribute("type", "button")
	section.appendChild(cancelButton)
	
	
	let referenceLabel = document.createElement("label")
	referenceLabel.setAttribute("for", `reference-${number}-destination`)
	referenceLabel.textContent = "Reference"
	contents.appendChild(referenceLabel)
	
	let referenceSelect = document.createElement("select")
	referenceSelect.classList.add("reference-select")
	referenceSelect.id = `reference-${number}-destination`
	referenceSelect.required = true
	contents.appendChild(referenceSelect)
	fetchOptions(number)
	referenceSelect.focus()
	
	
	let commentLabel = document.createElement("label")
	commentLabel.setAttribute("for", `reference-${number}-comment`)
	commentLabel.textContent = "Comment"
	contents.appendChild(commentLabel)
	
	let commentInput = document.createElement("input")
	commentInput.classList.add("reference-comment-input")
	commentInput.id = `reference-${number}-comment`
	commentInput.setAttribute("type", "text")
	commentInput.setAttribute("placeholder", "Comment")
	commentInput.setAttribute("title", "Comment")
	commentInput.setAttribute("inputmode", "text")
	contents.appendChild(commentInput)
}

function fetchOptions(number, newValue) {
	let select = document.getElementById(`reference-${number}-destination`)
	
	if (allWords.length > 0) {
		appendWordOptions(allWords, select)
		if (newValue) select.value = newValue
	} else if (wordFetchTask) {
		wordFetchTask.then(async (words) => {
			if (words) {
				appendWordOptions(words, select)
				if (newValue) select.value = newValue
			} else {
				reportWordFetchError("Unable to fetch words.", select)
			}
		})
		.catch(() => {
			reportWordFetchError("Unable to fetch words.", select)
		})
	} else {
		let option = document.createElement("option")
		option.disabled = true
		option.selected = true
		option.value = ""
		option.textContent = "Loading…"
		select.appendChild(option)
		
		wordFetchTask = fetch("/words", {
			method: "GET",
		})
		.then(async (response) => {
			wordFetchTask = null
			
			if (response.ok) {
				let words = await response.json()
				allWords = words
				
				appendWordOptions(words, select)
				if (newValue) select.value = newValue
				return words
			} else {
				reportWordFetchError("Unable to fetch words.", select)
				return null
			}
		})
		.catch(() => {
			wordFetchTask = null
			reportWordFetchError("Unable to fetch words.", select)
		})
	}
}

function appendWordOptions(words, select) {
	select.innerHTML = ""
	
	let defaultOption = document.createElement("option")
	defaultOption.textContent = "Select a word"
	defaultOption.disabled = true
	defaultOption.selected = true
	defaultOption.value = ""
	select.appendChild(defaultOption)
	
	for (let word of words) {
		let option = document.createElement("option")
		option.setAttribute("value", word.id)
		option.setAttribute("wordType", word.value.type)
		option.textContent = `${word.value.string} (${describeWordType(word.value.type)})`

		if (word.value.translations && word.value.translations.length > 0) {
			option.textContent += " – "
			for (let i in word.value.translations) {
				let translation = word.value.translations[i]
				option.textContent += translation.value.translation

				if (i < word.value.translations.length-1) option.textContent += ", "
			}
		}
		
		select.appendChild(option)
	}
}

function reportWordFetchError(error, select) {
	select.innerHTML = ""

	let option = document.createElement("option")
	option.disabled = true
	option.selected = true
	option.value = ""
	option.textContent = error
	select.appendChild(option)
}

function removeReference(number) {
	let section = document.getElementById(`reference-${number}`)
	section.remove()
}


async function submitItem() {
	let button = document.getElementById("submit")
	button.disabled = true
	button.textContent = "Sending data…"
	
	let string = document.getElementById("string").value
	let type = document.getElementById("type").value

	let translations = []
	let references = []

	for (let child of document.getElementById("translations").children) {
		if(!child.classList.contains("removable-section"))
			continue

		let translation = document.getElementById(`${child.id}-value`).value
		let comment = document.getElementById(`${child.id}-comment`).value

		translations.push({
			translation: translation,
			comment: comment,
		})
	}
	
	for (let child of document.getElementById("references").children) {
		if(!child.classList.contains("removable-section"))
			continue
		
		let destinationID = document.getElementById(`${child.id}-destination`).value
		let comment = document.getElementById(`${child.id}-comment`).value
		
		references.push({
			destinationID: destinationID,
			comment: comment,
		})
	}

	let data = {
		string: string,
		type: type,
		translations: translations,
		references: references,
	}

	let error = document.getElementById("submit-error")
	let success = document.getElementById("submit-success")

	try {
		let response = await fetch(window.location.href, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify(data)
		})

		if (response.ok && await response.json()) {
			button.disabled = false
			button.textContent = "Submit"
			
			success.hidden = false
			error.hidden = true
			
			allWords = []
			handleSuccess()
		} else {
			button.disabled = false
			button.textContent = "Submit"
			
			success.hidden = true
			error.hidden = false
			error.textContent = "Request failed."
		}
	} catch {
		button.disabled = false
		button.textContent = "Submit"
		
		success.hidden = true
		error.hidden = false
		error.textContent = "Unable to send request."
	}
}
