function handleSuccess() {
	document.getElementById("input-form").reset()
	document.getElementById("string").focus()
	
	let sectionsToRemove = []
	for (let section of document.getElementById("translations").children) {
		if (section.classList.contains("removable-section")) sectionsToRemove.push(section)
	}
	for (let section of document.getElementById("references").children) {
		if (section.classList.contains("removable-section")) sectionsToRemove.push(section)
	}
	
	for (let section of sectionsToRemove) {
		section.remove()
	}
}
