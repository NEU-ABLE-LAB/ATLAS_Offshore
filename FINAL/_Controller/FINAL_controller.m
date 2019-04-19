function y = FINAL_controller(u)
%MY_CONTROLLER Compute MLC control logic
%
%   u - (111x1) The 110x1 vector of FAST outputs plus an element at the end
%   specifying which of the 6 controllers is being used
%
%   y - (1x1) the control logic output

y(1)=(cos((cos((my_div(my_log(((-0.5459) + u(7))),cos((9.911 * (-1.934)))))) - (cos(((5.64 - u(4)) - cos((-1.529)))) - (((my_div(u(5),u(3))) + ((-1.294) * (-3.319))) * (cos((-9.491)) + (1.815 * 3.846)))))) * my_log((my_div(sin(sin(((8.113 * u(5)) - (my_div((-3.274),u(25)))))),cos(my_log(((u(74) - (-5.668)) - (u(74) - u(46)))))))));
y(2)=my_log((my_div((my_log(sin(sin(my_log(u(46))))) - sin(my_log(cos(cos(my_log(sin(sin(u(26))))))))),(sin(((my_div((my_div(6.979,(-2.933))),cos(u(47)))) * (sin((-1.702)) - (my_div(u(4),(-6.916)))))) - sin(sin(cos((u(34) * (-0.4034)))))))));
y(3)=((my_div(((sin(cos(sin((-1.327)))) + sin(sin((0.266 + (-6.804))))) - (my_div(cos((my_div(((-2.181) - 3.533),my_log(u(34))))),sin(cos((8.82 - u(34))))))),sin((my_log(cos((9.535 * 7.438))) - cos((cos((-7.867)) - cos(8.409))))))) + my_log(sin((my_div(sin(((9.515 * (-9.647)) * (my_div(u(46),7.847)))),(my_log(sin(u(7))) * (my_div(((-4.264) - (-0.2901)),my_log(u(24))))))))));
y(4)=(my_div((sin(((cos(((-1.228) * 8.756)) - my_log((u(99) - u(24)))) * my_log((my_log(2.064) - my_log(0.2148))))) * (sin(((((-6.687) - (-9.336)) * sin(8.851)) * (my_div(sin(u(25)),((-9.121) + 2.803))))) * sin(my_log((my_log(0.5398) + sin(2.307)))))),((my_div((my_log(cos(sin(6.134))) * (my_log(sin((-7.722))) * (my_log((-0.3245)) + ((-2.677) * (-6.922))))),my_log(sin((my_div(my_log(6.591),cos(u(25)))))))) + my_log((my_div(((((-1.719) * 9.314) - cos((-1.156))) + (my_div((u(74) - u(34)),my_log(2.246)))),cos(my_log((u(6) - u(74))))))))));
y(5)=(((cos((((u(6) + 1.915) + (my_div(u(24),u(3)))) + (my_log(u(99)) * (my_div((-5.656),(-1.208)))))) - (my_div(cos(cos(((my_div((-6.021),(-4.139))) + ((-8.9) + (-2.656))))),(my_log((u(7) - u(91))) + (sin(8.918) - my_log(u(91))))))) + sin((sin(my_log(sin(0.1211))) - ((u(7) * ((-3.19) * (-3.484))) * my_log((7.294 + (-5.509))))))) * sin((my_div(my_log(((sin(u(7)) - (1.388 + (-0.1721))) + (((-1.37) + u(9)) * (u(46) - u(4))))),(my_div((((1.596 * (-6.529)) + (2.923 * 3.235)) - (my_log(u(91)) - (u(74) - 9.278))),cos((cos(2.641) * my_log(6.844)))))))));
y(6)=sin(((my_div(sin((my_div((((-9.56) * 8.443) * (my_div((-8.997),(-1.373)))),((my_div((-0.9073),4.364)) + ((-1.865) + u(5)))))),((cos(my_log(u(10))) * (my_div(cos(8.295),(5.977 * u(24))))) - sin(((u(99) * (-4.318)) - (6.972 - (-0.02425))))))) * (cos(my_log((cos((-7.418)) * (my_div(6.554,u(9)))))) + ((((1.658 - u(9)) * (my_div(u(24),u(26)))) + (((-9.696) - (-8.625)) + (3.625 - (-5.931)))) - (my_log((my_div((-4.676),0.6395))) + cos((u(74) + u(91))))))));
     
y = y(u(end));
    
end

