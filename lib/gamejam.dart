import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:box2d_flame/box2d.dart';

class GameJam extends BaseGame with TapDetector{
  World _world;
  BodyDef bodyDef = BodyDef();

  GameJam() : _world = World.withGravity(Vector2(0,20)){
    addStaticBox();
    addCircle();
  }

  @override
  void onTapDown(TapDownDetails tapDownDetails){
    bodyDef.type = BodyType.KINEMATIC;
    bodyDef.position = Vector2(tapDownDetails.globalPosition.dx,tapDownDetails.globalPosition.dy);
    bodyDef.linearVelocity = Vector2(0,-50);

    var createKinematicBody = _world.createBody(bodyDef);
    var boxShape = PolygonShape();
    boxShape.setAsBox(10, 10, Vector2(0,0), 0);

    var fixtureDef = FixtureDef();
    fixtureDef.density = 1;
    fixtureDef.shape = boxShape;

    createKinematicBody.createFixtureFromFixtureDef(fixtureDef);
  }


  addStaticBox(){
    bodyDef.type = BodyType.STATIC;
    bodyDef.position = Vector2(100,300);

    var createBody = _world.createBody(bodyDef);

    var boxShape = PolygonShape();
    boxShape.setAsBox(100, 10, Vector2(10,0), 0.2);

    var fixtureDef = FixtureDef();
    fixtureDef.density = 1;
    fixtureDef.shape = boxShape;
    fixtureDef.friction = 0;

    createBody.createFixtureFromFixtureDef(fixtureDef);
  }

  addCircle(){
    for(int i = 0; i<=50; i ++){
      var fixtureDef = FixtureDef();
      var circleShape = CircleShape();
      circleShape.p.setFrom(Vector2(0,0));
      circleShape.radius = 10;

      bodyDef.type = BodyType.DYNAMIC;
      bodyDef.position = Vector2(100, 200);

      var circleBody = _world.createBody(bodyDef);
      fixtureDef.shape = circleShape;
      fixtureDef.restitution = 0.5;

      circleBody.createFixtureFromFixtureDef(fixtureDef);
    }
  }




  @override
  void render(Canvas canvas){
    Paint bgPaint = Paint()..color = Colors.white;
    Rect bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(bgRect, bgPaint);

    _world.forEachBody((body) {
      for(var fixture = body.getFixtureList();
      fixture != null;
      fixture = fixture.getNext()){

        final Shape shape = fixture.getShape();
        if(shape is CircleShape){
          canvas.save();

          canvas.translate(body.position.x, body.position.y);
          Paint _paint = Paint()
            ..color = Colors.black.withOpacity(0.5)
            ..strokeWidth = 3;


          canvas.drawCircle(Offset(shape.p.x, shape.p.y), shape.radius, _paint);
          canvas.restore();
        } else if (shape is PolygonShape){
          final List<Vector2> vertices =
          Vec2Array().get(shape.count);

          for (int i = 0; i < shape.count; ++i) {
            body.getWorldPointToOut(shape.vertices[i],
                vertices[i]); // Copy world point to our List.
          }

          final List<Offset> points = [];
          for (int i = 0; i < shape.count; i++) {
            points.add(Offset(
                vertices[i].x, vertices[i].y)); // Convert Vertice to Offset.
          }

          final path = Path()
            ..addPolygon(
                points, true); // Create a path based on the points and draw it.

          canvas.drawPath(
            path,
            Paint()
              ..color = Colors.purple
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5,
          );
          canvas.drawPath(path, Paint()..color = Colors.greenAccent.withAlpha(50));

        }
      }
    });

    super.render(canvas);
  }

  @override
  void update(double t) {
    var velocityIterations = 10;
    var positionIterations = 10;
    _world.stepDt(t, velocityIterations, positionIterations);

    super.update(t);

  }
}