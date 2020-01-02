/*
* Copyright (c) 2019 Alecaddd (http://alecaddd.com)
*
* This file is part of Akira.
*
* Akira is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* Akira is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with Akira.  If not, see <https://www.gnu.org/licenses/>.
*
* Authored by: Giacomo Alberini <giacomoalbe@gmail.com>
*/

public class Akira.Lib.Managers.SelectedBoundManager : Object {

    public weak Goo.Canvas canvas { get; construct; }
    public unowned List<Models.CanvasItem> selected_items {
        get {
            return _selected_items;
        }
        set {
            _selected_items = value;

            update_selected_items ();

        }
    }

    private unowned List<Models.CanvasItem> _selected_items;
    private Goo.CanvasBounds select_bb;
    private double initial_event_x;
    private double initial_event_y;
    private double initial_width;
    private double initial_height;

    public SelectedBoundManager (Goo.Canvas canvas) {
        Object (
            canvas: canvas
        );
    }

    construct {
        reset_selection ();
    }

    public void set_initial_coordinates (double event_x, double event_y) {
        if (selected_items.length () == 1) {
            var selected_item = selected_items.nth_data (0);

            initial_event_x = event_x;
            initial_event_y = event_y;

            canvas.convert_to_item_space (selected_item, ref initial_event_x, ref initial_event_y);

            initial_width = selected_item.get_coords ("width");
            initial_height = selected_item.get_coords ("height");
        } else {
            initial_event_x = event_x;
            initial_event_y = event_y;

            initial_width = select_bb.x2 - select_bb.x1;
            initial_height = select_bb.y2 - select_bb.y1;
        }
    }

    public void transform_bound (double event_x, double event_y, Managers.NobManager.Nob selected_nob) {
        Models.CanvasItem selected_item;
        selected_item = selected_items.nth_data (0);

        switch (selected_nob) {
            case Managers.NobManager.Nob.NONE:
                Utils.AffineTransform.move (
                    event_x, event_y,
                    initial_event_x, initial_event_y,
                    selected_item
                );
                break;

            case Managers.NobManager.Nob.ROTATE:
                Utils.AffineTransform.rotate (
                    event_x, event_y,
                    initial_event_x, initial_event_y,
                    selected_item
                );
                break;

            default:
                Utils.AffineTransform.scale (
                    event_x, event_y,
                    ref initial_event_x, ref initial_event_y,
                    initial_width, initial_height,
                    selected_nob,
                    selected_item
                );
                break;
        }

        update_selected_items ();
    }

    public void add_item_to_selection (Models.CanvasItem item) {
        item.selected = true;

        selected_items.append (item);
    }

    public void delete_selection () {
        foreach (var item in selected_items) {
            item.delete ();
        }

        // By emptying the selected_items list, the select_effect get dropped
        selected_items = new List<Models.CanvasItem> ();
    }

    public void reset_selection () {
        foreach (var item in selected_items) {
            item.selected = false;
        }

        selected_items = new List<Models.CanvasItem> ();
    }

    private void update_selected_items () {
        event_bus.selected_items_changed (selected_items);
    }
}
