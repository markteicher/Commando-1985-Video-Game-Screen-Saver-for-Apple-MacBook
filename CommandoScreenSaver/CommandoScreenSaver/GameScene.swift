import AppKit
final class GameScene {
    private var size:CGSize; private var player:Player; private var enemies:[Enemy]=[]
    private var shots:[Projectile]=[]; private var blasts:[Explosion]=[]; private var terrain=Terrain()
    private var enemyClock=0.0, fireClock=0.0, grenadeClock=0.0, elapsed=0.0; private var score=0
    init(size:CGSize){self.size=size; player=Player(position:CGPoint(x:size.width/2,y:size.height*0.2)); terrain.reset(size:size)}
    func reset(size:CGSize){self.size=size; enemies=[];shots=[];blasts=[];score=0;elapsed=0;player.position=CGPoint(x:size.width/2,y:size.height*0.2);terrain.reset(size:size)}
    func resize(to s:CGSize){if s != size {size=s;terrain.resize(size:s)}}
    func update(dt:TimeInterval){
        guard size.width>1 && size.height>1 else{return}; elapsed+=dt;terrain.update(dt:dt,size:size)
        player.position=CGPoint(x:size.width/2+CGFloat(sin(elapsed*.72))*min(size.width*.28,250),y:size.height*.2+CGFloat(sin(elapsed*1.35))*15)
        fireClock+=dt; if fireClock>.14{fireClock=0;shots.append(Projectile(position:CGPoint(x:player.position.x,y:player.position.y+20),velocity:CGVector(dx:0,dy:520),type:.playerBullet))}
        grenadeClock+=dt;if grenadeClock>3.1{grenadeClock=0;shots.append(Projectile(position:player.position,velocity:CGVector(dx:CGFloat.random(in:-55...55),dy:290),type:.grenade))}
        enemyClock+=dt;if enemyClock>.55{enemyClock=0;enemies.append(Enemy(position:CGPoint(x:CGFloat.random(in:36...max(36,size.width-36)),y:size.height+28)))}
        for i in enemies.indices{
            enemies[i].update(dt:dt,playerPosition:player.position)
            if Double.random(in:0...1)<dt*.48{let dx=player.position.x-enemies[i].position.x,dy=player.position.y-enemies[i].position.y,l=max(1,hypot(dx,dy));shots.append(Projectile(position:enemies[i].position,velocity:CGVector(dx:dx/l*215,dy:dy/l*215),type:.enemyBullet))}
        }
        enemies.removeAll{$0.position.y < -60}
        for i in shots.indices{shots[i].update(dt:dt)}
        for p in shots where p.type == .grenade && p.age >= .9 {blasts.append(Explosion(position:p.position,maximumRadius:48))}
        shots.removeAll{($0.type == .grenade && $0.age >= .9)||$0.position.y > size.height+100||$0.position.y < -100}
        var eh=Set<Int>(),ph=Set<Int>()
        for pi in shots.indices where shots[pi].type == .playerBullet{
            for ei in enemies.indices where !eh.contains(ei){
                if hypot(shots[pi].position.x-enemies[ei].position.x,shots[pi].position.y-enemies[ei].position.y)<16{eh.insert(ei);ph.insert(pi);blasts.append(Explosion(position:enemies[ei].position,maximumRadius:26));score+=100;break}
            }
        }
        for i in eh.sorted(by:>){enemies.remove(at:i)};for i in ph.sorted(by:>){shots.remove(at:i)}
        for i in blasts.indices{blasts[i].update(dt:dt)};blasts.removeAll{$0.isFinished}
    }
    func draw(in c:CGContext,bounds:CGRect){
        c.saveGState();c.setShouldAntialias(false);terrain.draw(in:c,bounds:bounds)
        enemies.forEach{$0.draw(in:c)};shots.forEach{$0.draw(in:c)};player.draw(in:c);blasts.forEach{$0.draw(in:c)}
        NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=NSGraphicsContext(cgContext:c,flipped:false)
        String(format:"1UP  %06d       HIGH SCORE  100000",score).draw(at:CGPoint(x:18,y:max(8,size.height-27)),withAttributes:[.font:NSFont.monospacedSystemFont(ofSize:15,weight:.bold),.foregroundColor:NSColor.white])
        NSGraphicsContext.restoreGraphicsState();c.restoreGState()
    }
}
