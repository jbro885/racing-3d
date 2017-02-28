app.objects.bot = function(car,path){

    this.car = car;
    this.path = path;

    this.state = 0;

    this.targetPosition = this.path[(this.state+1)%this.path.length].position;
    this.position = this.path[this.state].position;
    this.speed = this.path[this.state].speed;


    this.rotation = calcTargetRot(this.position,this.targetPosition);
    this.targetRotation = [0,0,0];
    this.rotationSpeed = 0.005;

    if (this.speed === 0) this.speed = this.car.maxSpeed;

    console.log(this.speed);

    this.render = function(gl,shader){
        this.car.render(gl,shader);
    };

    var count = 0;

    this.update = function(deltaTime){
        var dir = vec3.clone(this.targetPosition);
        vec3.subtract(dir,dir,this.position);
        var distance = vec3.length(dir);
        vec3.normalize(dir,dir);

        var step = deltaTime*this.speed;
        //console.log(distance);
        //console.log(step);
        var nDist = vec3.clone(dir);
        vec3.scale(nDist,nDist,step);
        var futureLength = vec3.length(nDist);

        if (futureLength>=distance){
            vec3.scale(dir,dir,step);
            vec3.add(this.position,this.position,dir);
            //this.position = this.targetPosition;
            this.updateState();
        } else {
            vec3.scale(dir,dir,step);
            vec3.add(this.position,this.position,dir);
        }

        var rotDiff = this.targetRotation[1]%(2*Math.PI)-this.rotation[1]%(2*Math.PI);
        var rotDir = 1.0;
        if (rotDiff<0) {
            rotDir *=-1;
        }
        if (Math.abs(rotDiff)>Math.PI) {
            rotDiff = rotDiff<0? -(2*Math.PI-rotDiff) : 2*Math.PI*rotDiff;
            rotDir *=-1;
        }

        if (this.rotation!=this.targetRotation)
            step = rotDir*this.rotationSpeed * deltaTime;
        //step = this.rotationSpeed*deltaTime;

        if (Math.abs(rotDiff)<Math.abs(step)) this.rotation = this.targetRotation;
        else this.rotation[1]+=step;

        this.car.wheelXAngle += this.speed*deltaTime/this.car.wheelRadius;

        car.position = this.position;
        //car.rotation = this.targetRotation;
        car.rotation = this.rotation;
    };

    this.updateState = function(){
        this.state++;
        if (this.state==this.path.length) this.state = 0;
        //console.log(this.state);
        //console.log(this.path.length);
        this.targetPosition = this.path[(this.state+1)%this.path.length].position;
        //this.position = this.path[this.state].position;

        //this.speed = this.car.maxSpeed;
        this.speed = this.path[this.state].speed;
        if (this.speed === 0 ) this.speed = this.car.maxSpeed/3;

        var rotation = vec3.clone(this.targetPosition);
        vec3.subtract(rotation,rotation,this.position);
        var angle = Math.atan2(rotation[2],rotation[0]);


        //this.rotation = this.targetRotation;
        this.targetRotation = [0,-angle+Math.PI/2,0];
    };

    function calcTargetRot(p1,p2){
        var rotation = vec3.clone(p2);
        vec3.subtract(rotation,rotation,p1);
        var angle = Math.atan2(rotation[2],rotation[0]);
        return [0,-angle+Math.PI/2,0];
    }

};