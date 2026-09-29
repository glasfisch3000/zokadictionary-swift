let translationNumber = 0
let referenceNumber = 0
let wordFetchTask = null

function addTranslation() {
	let translations = document.getElementById("translations")
	
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
	cancelButton.classList.add("small-button")
	cancelButton.classList.add("destructive")
	cancelButton.textContent = "􀆄"
	cancelButton.setAttribute("onClick", `removeTranslation(${number})`)
	cancelButton.setAttribute("type", "button")
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
	translationInput.required = true
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

function removeTranslation(number) {
	let section = document.getElementById(`translation-section-${number}`)
	section.remove()
}


let allWords = []
function addReference() {
	let references = document.getElementById("references")
	
	referenceNumber += 1
	let number = referenceNumber
	
	let section = document.createElement("section")
	section.id = `reference-section-${number}`
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
	referenceLabel.setAttribute("for", `reference-${number}`)
	referenceLabel.textContent = "Reference"
	contents.appendChild(referenceLabel)
	
	let referenceSelect = document.createElement("select")
	referenceSelect.classList.add("reference-select")
	referenceSelect.id = `reference-${number}`
	referenceSelect.required = true
	contents.appendChild(referenceSelect)

	if (allWords.length > 0) {
		appendWordOptions(allWords, referenceSelect)
	} else if (wordFetchTask) {
		wordFetchTask.then(async (response) => {
			if (response.ok) {
				let words = await response.json()
				allWords = words
				appendWordOptions(words, referenceSelect)
			} else {
				reportWordFetchError("Unable to fetch words", referenceSelect)
			}
		})
		.catch(() => {
			reportWordFetchError("Unable to fetch words", referenceSelect)
		})
	} else {
		let option = document.createElement("option")
		option.disabled = true
		option.selected = true
		option.value = ""
		option.textContent = "Loading…"
		referenceSelect.appendChild(option)

		wordFetchTask = fetch("/words", {
			method: "GET",
		})
		
		wordFetchTask.then(async (response) => {
			if (response.ok) {
				let words = await response.json()
				allWords = words
				appendWordOptions(words, referenceSelect)
			} else {
				reportWordFetchError("Unable to fetch words", referenceSelect)
			}
		})
		.catch(() => {
			reportWordFetchError("Unable to fetch words", referenceSelect)
		})
	}
	
	let commentLabel = document.createElement("label")
	commentLabel.setAttribute("for", `reference-comment-${number}`)
	commentLabel.textContent = "Comment"
	contents.appendChild(commentLabel)
	
	let commentInput = document.createElement("input")
	commentInput.classList.add("reference-comment-input")
	commentInput.id = `reference-comment-${number}`
	commentInput.setAttribute("type", "text")
	commentInput.setAttribute("placeholder", "Comment")
	commentInput.setAttribute("title", "Comment")
	commentInput.setAttribute("inputmode", "text")
	contents.appendChild(commentInput)
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
		option.textContent = `${word.value.string} (${describeWordType(word.value.type)})`
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
	let section = document.getElementById(`reference-section-${number}`)
	section.remove()
}


async function submitNewItem() {
	let string = document.getElementById("string").value
	let type = document.getElementById("type").value

	let translations = []
	let references = []

	for (let i = 1; i<=translationNumber; i++) {
		if(!document.getElementById(`translation-section-${i}`))
			continue

		let translation = document.getElementById(`translation-${i}`).value
		let comment = document.getElementById(`translation-comment-${i}`).value

		translations.push({
			translation: translation,
			comment: comment,
		})
	}

	for (let i = 1; i<=referenceNumber; i++) {
		if(!document.getElementById(`reference-section-${i}`))
			continue

		let destinationID = document.getElementById(`reference-${i}`).value
		let comment = document.getElementById(`reference-comment-${i}`).value

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
		let response = await fetch("/new-item", {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify(data)
		})

		if (response.ok) {
			success.hidden = false
			error.hidden = true
			
			clearForm()
		} else {
			success.hidden = true
			error.hidden = false
			error.textContent = "Request failed"
		}
	} catch {
		success.hidden = true
		error.hidden = false
		error.textContent = "Unable to send request"
	}
}

function clearForm() {
	document.getElementById("input-form").reset()
	
	for (let section of document.getElementById("translations").children) {
		if (section.classList.contains("removable-section")) section.remove()
	}
	
	for (let section of document.getElementById("references").children) {
		if (section.classList.contains("removable-section")) section.remove()
	}
}
