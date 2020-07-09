import 'package:FirstFlutter/app_container_animate.dart';
import 'package:FirstFlutter/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('AnimateWidget')),
        body: DraggableCard(
            child: FlutterLogo(
              size: 128,
            ),
            child2: RaisedButton(
                onPressed: () => {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AppContainerAnimate()))
                    },
                color: Colors.blue,
                child: Text(
                  'TEST ja',
                  style: TextStyle(color: Colors.white),
                ))));
  }
}

class DraggableCard extends StatefulWidget {
  final Widget child;
  final Widget child2;
  DraggableCard({this.child, this.child2});

  @override
  State<StatefulWidget> createState() {
    return _DraggableCardState();
  }
}

class _DraggableCardState extends State<DraggableCard>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Alignment _dragAlignment = Alignment.center;
  Animation<Alignment> _animation;

  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );
    // _controller.reset();
    // _controller.forward();
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.addListener(() {
      setState(() {
        LogUtils.info('_animation.value : ' + _animation.value.toString());
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
        onPanDown: (details) {
          _controller.stop();
        },
        onPanUpdate: (details) {
          setState(() {
            _dragAlignment += Alignment(
              details.delta.dx / (size.width / 2),
              details.delta.dy / (size.height / 2),
            );
          });
        },
        onPanEnd: (details) {
          _runAnimation(details.velocity.pixelsPerSecond, size);
        },
        // child: Align(
        //     alignment: _dragAlignment,
        //     child: Card(
        //       child: widget.child,
        //     )),
        child: new Column(children: [
          new Container(
            height: MediaQuery.of(context).copyWith().size.height / 2,
            child: Align(
                alignment: _dragAlignment,
                child: Card(
                  child: widget.child,
                )),
          ),
          new Container(
            child: widget.child2,
          )
        ]));
  }
}
