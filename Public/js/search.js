let searchButton = document.getElementById("search-button-input")
let controller = new AbortController()
searchButton.addEventListener("change", (event) => {
	if (searchButton.checked) {
		searchInput.focus()
	} else {
		controller.abort()
		cancelSearch()
		searchInput.value = ""
	}
})

let searchInput = document.getElementById("search-input")
let searchResults = document.getElementById("search-results")
searchInput.addEventListener("input", (event) => {
	controller.abort()
	if (!searchInput.value) {
		return
	}
	
	controller = new AbortController()
	
	fetch("/words?search=" + encodeURIComponent(searchInput.value), {
		method: "get",
		signal: controller.signal,
	})
	.then(applySearch)
	.catch(cancelSearch)
})

async function applySearch(response) {
	searchResults.textContent = ""
	
	if (response.ok) {
		let words = await response.json()
		for (let word of words) {
			let parent = document.createElement("a")
			parent.classList.add("search-item")
			parent.href = `/words/${word.id}`
			searchResults.appendChild(parent)
			
			let info = document.createElement("div")
			info.classList.add("item-info")
			parent.appendChild(info)
			
			let title = document.createElement("div")
			title.classList.add("item-title")
			title.textContent = word.value.string
			info.appendChild(title)
			
			let type = document.createElement("span")
			voices.classList.add("item-type")
			voices.textContent = ` (${word.value.type})`
			title.appendChild(voices)
			
			if (word.value.translation.length > 0) {
				let translations = document.createElement("div")
				translations.classList.add("item-other-info")
				translations.textContent = "Translations: "
				info.appendChild(translations)
				
				for (let translation of word.value.translations) {
					let item = document.createElement("span")
					item.classList.add("item-translation")
					item.textContent = translation.value.translation
					translations.appendChild(item)
				}
			}
			
			if (word.value.references.length > 0) {
				let references = document.createElement("div")
				references.classList.add("item-other-info")
				references.textContent = "References: "
				info.appendChild(references)
				
				for (let reference of word.value.references) {
					let item = document.createElement("span")
					item.classList.add("item-reference")
					item.textContent = reference.value.destination.value.string
					references.appendChild(item)
				}
			}
		}
	} else {
		let error = document.createElement("div")
		error.classList.add("error")
		error.textContent = "Search failed"
		searchResults.prepend(error)
	}
}

function cancelSearch(error) {
	searchResults.innerHTML = ""

	let error = document.createElement("div")
	error.classList.add("error")
	error.textContent = "Search failed"
	searchResults.prepend(error)
}
