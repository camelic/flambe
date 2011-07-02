import flambe.animation.Easing;
import flambe.display.Sprite;
import flambe.display.FillSprite;
import flambe.display.Transform;
import flambe.display.AnimatedSprite;
import flambe.script.Script;
import flambe.script.AnimateTo;
import flambe.script.Parallel;
import flambe.script.Sequence;
import flambe.script.CallFunction;
import flambe.Entity;
import flambe.System;
import flambe.Input;

class Main
{
    public static var IDLE = new Animation(100, [ 15, 16, 17, 16 ]).loop();
    public static var WALKING = new Animation(100, [ 36, 37, 38, 37 ]).loop();
    public static var PUNCH = new Animation(100, [ 3, 9, 4, 5, 9, 10, 11, 10, 3 ]);

    private static function onSuccess ()
    {
        var character = new Entity()
            .add(new AnimatedSprite(_loader.pack.createTexture("avatar.png"), 6, 8))
            .add(new Script());

        sprite.play(IDLE);

        // Put the anchor near his feet
        var sprite = character.get(AnimatedSprite);
        sprite.anchorX._ = sprite.getNaturalWidth()/2;
        sprite.anchorY._ = sprite.getNaturalHeight();

        // Put it in the middle of the stage
        var transform = character.get(Transform);
        transform.x._ = System.stageWidth/2;
        transform.y._ = System.stageHeight/2;

        Input.mouseDown.connect(function (event) {
            // Face left or right
            var transform = character.get(Transform);
            transform.scaleX._ = (event.viewX < transform.x._) ? 1 : -1;

            var delay = flambe.math.FMath.toInt(10*transform.distanceTo(event.viewX, event.viewY));
            var script = character.get(Script);
            script.stopAll();
            script.run(new Sequence([
                // TODO: This should be way less verbose, something like:
                // MoveTo.linear(event.viewX, event.viewY, delay),
                // new PlayAnimation(IDLE)
                new Parallel([
                    new AnimateTo(transform.x, event.viewX, delay, Easing.linear),
                    new AnimateTo(transform.y, event.viewY, delay, Easing.linear)
                ]),
                new CallFunction(function () {
                    sprite.play(IDLE);
                    sprite.play(PUNCH);
                }),
            ]));
            sprite.play(WALKING);
        });

        var world = new Entity().add(new Sprite()); // TODO: Requiring new Sprite() here is quirky
        // Add a background
        world.addChild(new Entity().add(
            new FillSprite(0x303030, System.stageWidth, System.stageHeight)));
        world.addChild(character);
        System.root.addChild(world);
    }

    private static function main ()
    {
        System.init();

        _loader = System.loadAssetPack("bootstrap");
        _loader.success.connect(onSuccess);
        _loader.error.connect(function (message) {
            trace("Load error: " + message);
        });
        _loader.start();
    }

    private static var _loader;
}