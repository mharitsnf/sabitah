extends Node

enum Islands {
	TUTORIAL
}

var entities: Dictionary = {
	Islands.TUTORIAL: {
		"teacher": null
	}
}

var dialogue_state: Dictionary = {
	Islands.TUTORIAL: {
		"teacher": {
			"intro": false
		},
		"townfolk_1": {
			"intro": false,
			"talked_to_teacher": false,
		}
	}
}