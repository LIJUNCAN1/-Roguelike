class_name Interactable
extends Area2D

signal interaction_requested(interaction_id: StringName)
signal focus_entered(interactable: Interactable, actor: Node)
signal focus_exited(interactable: Interactable, actor: Node)

@export var interaction_id: StringName
@export var display_name: String
@export var enabled: bool = true:
	set(value):
		enabled = value
		monitoring = value
		if not value:
			_clear_actor()

@onready var highlight: Node2D = $Highlight

var current_actor: Node
var _highlight_tween: Tween


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = enabled
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	highlight.visible = false
	_start_highlight_animation()


func _unhandled_input(event: InputEvent) -> void:
	if (
		not enabled
		or current_actor == null
		or not event.is_action_pressed("interact")
	):
		return
	interact(current_actor)
	get_viewport().set_input_as_handled()


func interact(actor: Node) -> void:
	if not enabled or actor == null:
		return
	interaction_requested.emit(interaction_id)


func get_prompt_text() -> String:
	return "E 交互\n%s" % display_name


func _on_body_entered(body: Node) -> void:
	if not enabled or not _is_player(body):
		return
	current_actor = body
	highlight.visible = true
	focus_entered.emit(self, body)


func _on_body_exited(body: Node) -> void:
	if body != current_actor:
		return
	focus_exited.emit(self, body)
	_clear_actor()


func _clear_actor() -> void:
	current_actor = null
	if is_instance_valid(highlight):
		highlight.visible = false


func _is_player(body: Node) -> bool:
	return (
		body is CharacterBody2D
		and body.get_node_or_null("MovementComponent") != null
	)


func _start_highlight_animation() -> void:
	if _highlight_tween != null:
		_highlight_tween.kill()
	_highlight_tween = create_tween().set_loops()
	_highlight_tween.tween_property(
		highlight,
		"position:y",
		-6.0,
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_highlight_tween.tween_property(
		highlight,
		"position:y",
		2.0,
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
