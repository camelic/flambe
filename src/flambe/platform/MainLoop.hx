//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.Component;
import flambe.display.DrawingContext;
import flambe.display.Sprite;
import flambe.display.Transform;
import flambe.Entity;
import flambe.scene.Director;
import flambe.System;
import flambe.Visitor;

/**
 * Updates all components and renders.
 */
class MainLoop
{
    public function new (drawCtx :DrawingContext)
    {
        _updateVisitor = new UpdateVisitor();
        _drawVisitor = new DrawVisitor(drawCtx);
    }

    public function update (dt :Int)
    {
        _updateVisitor.dt = dt;
        System.root.visit(_updateVisitor, true, true);
    }

    public function render ()
    {
        System.root.visit(_drawVisitor, false, true);
    }

    private var _updateVisitor :UpdateVisitor;
    private var _drawVisitor :DrawVisitor;
}

private class UpdateVisitor
    implements Visitor
{
    public var dt :Int;

    public function new ()
    {
    }

    public function enterEntity (entity :Entity) :Bool
    {
        return true;
    }

    public function leaveEntity (entity :Entity)
    {
    }

    public function acceptComponent (component :Component)
    {
        component.onUpdate(dt);
    }
}

private class DrawVisitor
    implements Visitor
{
    public function new (drawCtx :DrawingContext)
    {
        _drawCtx = drawCtx;
    }

    public function enterEntity (entity :Entity) :Bool
    {
        var director = entity.get(Director);
        if (director != null) {
            for (scene in director.scenes) {
                scene.visit(this, false, true);
            }
        }

        var sprite = entity.get(Sprite);
        if (sprite == null) {
            return true;
        }

        var n1 = sprite.alpha.get();
        if (!sprite.visible.get() || n1 < 0) {
            return false;
        }

        _drawCtx.save();

        if (n1 < 1) {
            _drawCtx.multiplyAlpha(n1);
        }

        if (sprite.blendMode != null) {
            _drawCtx.setBlendMode(sprite.blendMode);
        }

        var transform = entity.get(Transform);
        n1 = transform.x.get();
        var n2 = transform.y.get();
        if (n1 != 0 || n2 != 0) {
            _drawCtx.translate(n1, n2);
        }

        n1 = transform.rotation.get();
        if (n1 != 0) {
            _drawCtx.rotate(n1);
        }

        n1 = transform.scaleX.get();
        n2 = transform.scaleY.get();
        if (n1 != 1 || n2 != 1) {
            _drawCtx.scale(n1, n2);
        }

        n1 = sprite.anchorX.get();
        n2 = sprite.anchorY.get();
        if (n1 != 0 || n2 != 0) {
            _drawCtx.translate(-n1, -n2);
        }

        sprite.draw(_drawCtx);

        return true;
    }

    public function leaveEntity (entity :Entity)
    {
        _drawCtx.restore();
    }

    public function acceptComponent (component :Component)
    {
    }

    private var _drawCtx :DrawingContext;
}
