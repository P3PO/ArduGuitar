# pwmTest.py

from pyb import Pin, Timer,delay

#def pwmControl(pp = 'X1', tt = 2, f= 50000):
def pwmControl(pp = 'Y1', tim = 8, ch=1, f= 50000):
    """ returns an object that can set a duty cycle percentage, eg.
    >> c = pwmControl()
    >> c.pulse_width_percent(50)
    """
    p = Pin(pp) # X1 has TIM2, CH1, Y1 is tim8, ch1
    tim = Timer(tim, freq=f)
    return tim.channel(ch, Timer.PWM, pin=p)
    
def incP(control, current):
    """ usage
    cur = incP(c,cur)
    """
    print("Current %: " + str(current))
    control.pulse_width_percent(current)
    return current +1

def on(o,d=5):
    r = [0,10,20,30,40,50,60,70,80,90,100]
    for p in  r:
        o.pulse_width_percent(p)
        delay(d)

def off(o):
    o.pulse_width_percent(0)

def shunt(o, on=True, pOn=1):
    p = pOn if on else 0
    o.pulse_width_percent(p)


def lc(ap,conf,c):
    shunt(c,True)
    ap.loadConfig(conf)
    shunt(c,False)
