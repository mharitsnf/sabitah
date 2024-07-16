extends Node

enum Islands {
	TUTORIAL
}

var entities: Dictionary = {
	Islands.TUTORIAL: {
		"teacher": null,
		"townfolk1": null,
	}
}

var progress: Dictionary = {
	Islands.TUTORIAL: {
		"teacher": {
			"intro": false,
			"boat_key_given": false
		},
		"townfolk1": {
			"intro": false,
			"talked_to_teacher": false,
		}
	}
}