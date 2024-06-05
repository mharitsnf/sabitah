class_name DialogueCommand extends Command

@export var dialogue_res: DialogueResource
@export var dialogue_start: String = "start"

func action(_args: Array = []) -> Common.Promise:
    var menu_layer: MenuLayer = Group.first("menu_layer")
    await (menu_layer as MenuLayer).clear()
    
    # DialogueManager.show_example_dialogue_balloon(dialogue_res, dialogue_start)

    # var line: DialogueLine = await DialogueManager.get_next_dialogue_line(dialogue_res, dialogue_start)
    # print(line)
    # line = await DialogueManager.get_next_dialogue_line(dialogue_res, line.next_id)
    # print(line)
    
    DialogueManager.show_dialogue_balloon(dialogue_res, dialogue_start)
    
    return Common.Promise.new()