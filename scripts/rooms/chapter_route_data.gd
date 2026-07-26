class_name ChapterRouteData
extends RandomRouteData

@export var chapters: Array[ChapterData] = []


func get_chapter_for_room(room_index: int) -> ChapterData:
	for chapter in chapters:
		if chapter != null and chapter.contains_room(room_index):
			return chapter
	return null


func get_chapter_index_for_room(room_index: int) -> int:
	for index in chapters.size():
		var chapter := chapters[index]
		if chapter != null and chapter.contains_room(room_index):
			return index
	return -1
