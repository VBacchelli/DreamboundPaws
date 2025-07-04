# Tool script to generate collision shapes for all textures based on transparency
# This script scans the Assets directory for PNG files and creates ConvexPolygonShape2D
# resources using the convex hull of all non-transparent pixels.
# Usage: Run this script from the Godot editor or with --headless via the command line.
# Generated shapes are saved to res://Assets/CollisionShapes/

tool
extends Node

const ASSETS_DIR := "res://Assets"
const OUTPUT_DIR := "res://Assets/CollisionShapes"

func _ready() -> void:
    var dir := DirAccess.open(ASSETS_DIR)
    if dir == null:
        push_error("Cannot open Assets directory")
        return
    if not DirAccess.dir_exists_absolute(OUTPUT_DIR):
        DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
    _process_directory(dir, ASSETS_DIR)
    print("Collision shapes generated.")
    get_tree().quit()

func _process_directory(dir: DirAccess, path: String) -> void:
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if dir.current_is_dir():
            if file_name.begins_with('.'):
                pass
            else:
                var sub_path = path + "/" + file_name
                var sub_dir = DirAccess.open(sub_path)
                _process_directory(sub_dir, sub_path)
        else:
            if file_name.to_lower().ends_with('.png'):
                _generate_shape(path + "/" + file_name)
        file_name = dir.get_next()
    dir.list_dir_end()

func _generate_shape(tex_path: String) -> void:
    var tex = load(tex_path)
    if tex is Texture2D:
        var img = tex.get_image()
        img.lock()
        var points: PackedVector2Array = []
        for x in img.get_width():
            for y in img.get_height():
                var c = img.get_pixel(x, y)
                if c.a > 0.1:
                    points.append(Vector2(x - img.get_width() / 2.0, y - img.get_height() / 2.0))
        img.unlock()
        if points.size() == 0:
            return
        var hull := Geometry2D.convex_hull(points)
        var shape := ConvexPolygonShape2D.new()
        shape.points = hull
        var name = tex_path.get_file().get_basename() + "_shape.tres"
        var out_path = OUTPUT_DIR + "/" + name
        ResourceSaver.save(out_path, shape)
