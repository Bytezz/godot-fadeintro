## Coded by Bytez
## https://github.com/bytezz/godot-fadeintro
## ----
## Intro scene with fading pictures
## (for Godot Game Engine).

extends Control

signal finished

onready var Background = get_node("Background")
onready var Picture = get_node("CenterContainer/Picture")
onready var HoldTimer = get_node("HoldTimer")
onready var FadeAnimationPlayer = get_node("FadeAnimationPlayer")

## Pics to show with fades
export(Array, Texture) var pics
var picIndex = 0
## Width of image based on window size
export var sizePerc = 0.5
## Min width of image in pixels
export var minSizePx = 300
## Time for pics to stay still
export var holdSeconds = 1
## Length of fade in and fade out
export var fadeSeconds = 1
## Background color
export(Color) var backgroundColor = Color.black
## Do you want to be able to skip all the pics by pressing ui_accept?
export var enableSkip = true
export var skipControl = "ui_accept"
## The next scene to load after all pics (if [empty], will be just ignored)
export(PackedScene) var nextScene

var finished = false


func _ready():
	Background.color = backgroundColor
	
	if pics!=null and pics.size()>0:
		Picture.texture = pics[picIndex]
		
		# set picture size
		if get_viewport().size.x*sizePerc < minSizePx:
			Picture.rect_min_size = Vector2(minSizePx, minSizePx)
		else:
			Picture.rect_min_size = get_viewport().size*sizePerc
		
		FadeAnimationPlayer.playback_speed = FadeAnimationPlayer.get_animation("fadeIn").length / fadeSeconds
		FadeAnimationPlayer.play("fadeIn")


func _on_HoldTimer_timeout():
	FadeAnimationPlayer.play("fadeOut")


func _on_FadeAnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadeIn":
		HoldTimer.wait_time = holdSeconds
		HoldTimer.start()
	elif anim_name == "fadeOut":
		if picIndex+1 < pics.size():
			picIndex+=1
			Picture.texture = pics[picIndex]
			FadeAnimationPlayer.play("fadeIn")
		else:
			end()

func resizePic():
	if get_viewport().size.x*sizePerc < minSizePx:
		$CenterContainer/Picture.rect_min_size = Vector2(minSizePx, minSizePx)
	else:
		$CenterContainer/Picture.rect_min_size = get_viewport().size*sizePerc

func _on_FadeIntro_resized():
	resizePic()


func _input(event):
	if enableSkip:
		if event.is_action_pressed(skipControl):
			end()


func end():
	emit_signal("finished")
	finished = true
	
	if nextScene != null:
		# warning-ignore:return_value_discarded
		get_tree().change_scene(nextScene.get_path())
