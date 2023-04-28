extends Resource
class_name StoryElements

enum CHAPTERS {
	Prolouge, ## Prolouge
	CH1, ## Chapter 1: Friends and Family
	CH2, ## Chapter 2: The one i love the most
}

## Used for keeping track of story Progression and at what point in the story the player is currently in
@export var STORY_PROGRESS = 0
## Used for keeping track of what chapter the player is currently in
@export var CHAPTER = CHAPTERS.Prolouge

## Used to progress the story variable [br]
## return: the new variable set
func progress_story() -> int:
	STORY_PROGRESS += 1
	return STORY_PROGRESS

## Used to progress the CHAPTER variable [br]
## return: the new variable set
func progress_chapter() -> int:
	CHAPTER += 1
	return CHAPTER
