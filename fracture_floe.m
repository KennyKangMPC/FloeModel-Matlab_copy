function Floes=fracture_floe(Floe,N)
%%This function takes an input of floes and fractures each floe into a
%%specified number of smaller ones using Voronoi Tesselation
id ='MATLAB:polyshape:repairedBySimplify';
warning('off',id)
id3 ='MATLAB:polyshape:boundary3Points';
warning('off',id3)

Floes=[]; rho_ice = 920; 

for kk=1:length(Floe)
    floe = Floe(kk);
    
    in = 0;
    count = 0;
    while sum(in)<0.5
        if ~isempty(floe.interactions) && count < 10
            a = floe.interactions(:,4:5);
            center = mean(a-[floe.Xi floe.Yi],1);
            X = 2*(rand(N,1)-0.5).*sqrt(floe.rmax-abs(center(1)))+center(1);
            Y = 2*(rand(N,1)-0.5).*sqrt(floe.rmax-abs(center(2)))+center(2);
        else
            X = floe.rmax*(2*rand(N,1)-1);
            Y = floe.rmax*(2*rand(N,1)-1);
        end
        in = inpolygon(X,Y,floe.c_alpha(1,:)',floe.c_alpha(2,:));
        count = count+1;
    end
    
    %Create a box to be used that bounds the polyshape
    boundingbox=[-1 ,-1; 1,-1; 1,1; -1 ,1]*floe.rmax;
    worked = 1;
    while worked > 0.5
        [~, b,~,~,worked] = polybnd_voronoi([X Y],[floe.c_alpha]');
        if worked == 1
            X = floe.Xi+floe.rmax*(2*rand(N,1)-1);
            Y = floe.Yi+floe.rmax*(2*rand(N,1)-1);
        end
    end
    for i =1:length(b)
        a=regions(intersect(polyshape(floe.c_alpha'),polyshape(b{i})));
        
        %%Loop through all the new shapes to calculate the new properties of
        %%each
        for p=1:length(a)
%             FloeNEW.poly = rmholes(a(p));
%             [Xi,Yi] = centroid(FloeNEW.poly);
%             FloeNEW.area = area(FloeNEW.poly);
%             FloeNEW.mass = floe.mass*area(a(p))/floe.area;
%             FloeNEW.h = floe.mass*area(a(p))/(rho_ice*FloeNEW.area*floe.area);
%             FloeNEW.inertia_moment = PolygonMoments(FloeNEW.poly.Vertices,FloeNEW.h);
%             FloeNEW.c_alpha = [(FloeNEW.poly.Vertices-[Xi Yi])' [FloeNEW.poly.Vertices(1,1)-Xi; FloeNEW.poly.Vertices(1,2)-Yi]];
%             FloeNEW.c0 = FloeNEW.c_alpha;
%             FloeNEW.angles = polyangles(FloeNEW.poly.Vertices(:,1),FloeNEW.poly.Vertices(:,2));
%             FloeNEW.rmax = sqrt(max(sum((FloeNEW.poly.Vertices' - [Xi;Yi]).^2,1)));
%             % n=(fix(FloeNEW.rmax/dX)+1); n=dX*(-n:n);
%             % FloeNEW.Xg = n;
%             % FloeNEW.Yg = n;
%             % [X, Y]= meshgrid(n, n);
%             % FloeNEW.X = X;
%             % FloeNEW.Y = Y;
%             FloeNEW.strain = floe.strain;
%             FloeNEW.Stress = [0 0; 0 0];
%             FloeNEW.Fx = 0; FloeNEW.Fy = 0;
%             
%             FloeNEW.X = FloeNEW.rmax*(2*rand(1000,1) - 1);
%             FloeNEW.Y = FloeNEW.rmax*(2*rand(1000,1) - 1);
%             FloeNEW.A = inpolygon(FloeNEW.X,FloeNEW.Y,FloeNEW.c_alpha(1,:),FloeNEW.c_alpha(2,:));
%             % [in] = inpolygon(FloeNEW.X(:)+Xi, FloeNEW.Y(:)+Yi,FloeNEW.poly.Vertices(:,1),FloeNEW.poly.Vertices(:,2));
%             % FloeNEW.A=reshape(in,length(FloeNEW.X),length(FloeNEW.X));
%             
%             FloeNEW.Xi = floe.Xi+Xi; FloeNEW.Yi = floe.Yi+Yi; FloeNEW.alive = 1;
%             FloeNEW.alpha_i = 0; FloeNEW.Ui = floe.Ui; FloeNEW.Vi = floe.Vi;
%             FloeNEW.dXi_p = floe.dXi_p; FloeNEW.dYi_p = floe.dYi_p;
%             FloeNEW.dUi_p = floe.dUi_p; FloeNEW.dVi_p = floe.dVi_p;
%             FloeNEW.dalpha_i_p = 0; FloeNEW.ksi_ice = FloeNEW.area/floe.area*floe.ksi_ice;
%             FloeNEW.dksi_ice_p = floe.dksi_ice_p;
%             FloeNEW.interactions = [];
%             FloeNEW.potentialInteractions = [];
%             FloeNEW.collision_force = 0;
%             %         FloeNEW.fracture_force = 0;
%             FloeNEW.collision_torque = 0;
%             FloeNEW.OverlapArea = 0;
%             FloeNEW.Stress = zeros(2);
%             FloeNEW.Fx = floe.Fx*area(a(p))/floe.area;
%             FloeNEW.Fy = floe.Fy*area(a(p))/floe.area;

            FloeNEW.poly = rmholes(a(p));
            [Xi,Yi] = centroid(FloeNEW.poly);
            FloeNEW.area = area(FloeNEW.poly);
            FloeNEW.mass = floe.mass*area(a(p))/floe.area;
            FloeNEW.h = floe.mass*area(a(p))/(rho_ice*FloeNEW.area*floe.area);
            FloeNEW.c_alpha = [(FloeNEW.poly.Vertices-[Xi Yi])' [FloeNEW.poly.Vertices(1,1)-Xi; FloeNEW.poly.Vertices(1,2)-Yi]];
            FloeNEW.c0 = FloeNEW.c_alpha;
            FloeNEW.inertia_moment = PolygonMoments(FloeNEW.c0',FloeNEW.h);
            FloeNEW.angles = polyangles(FloeNEW.poly.Vertices(:,1),FloeNEW.poly.Vertices(:,2));
            FloeNEW.rmax = sqrt(max(sum((FloeNEW.poly.Vertices' - [Xi;Yi]).^2,1)));
            % n=(fix(FloeNEW.rmax/dX)+1); n=dX*(-n:n);
            % FloeNEW.Xg = n;
            % FloeNEW.Yg = n;
            % [X, Y]= meshgrid(n, n);
            % FloeNEW.X = X;
            % FloeNEW.Y = Y;
            FloeNEW.strain = floe.strain;
            FloeNEW.Stress = floe.Stress*area(a(p))/floe.area;
            FloeNEW.MaxShear = floe.MaxShear*area(a(p))/floe.area;
            FloeNEW.Fx = floe.Fx; FloeNEW.Fy = floe.Fy;
            FloeNEW.FxOA = 0; FloeNEW.FyOA = 0; FloeNEW.torqueOA = 0;
            
            err = 1;
            while err > 0.1
                FloeNEW.X = FloeNEW.rmax*(2*rand(1000,1) - 1);
                FloeNEW.Y = FloeNEW.rmax*(2*rand(1000,1) - 1);
                FloeNEW.A = inpolygon(FloeNEW.X,FloeNEW.Y,FloeNEW.c_alpha(1,:),FloeNEW.c_alpha(2,:));
                err = (sum(FloeNEW.A)/1000*4*FloeNEW.rmax^2-FloeNEW.area)/FloeNEW.area;
            end
            % [in] = inpolygon(FloeNEW.X(:)+Xi, FloeNEW.Y(:)+Yi,FloeNEW.poly.Vertices(:,1),FloeNEW.poly.Vertices(:,2));
            % FloeNEW.A=reshape(in,length(FloeNEW.X),length(FloeNEW.X));
            
            FloeNEW.Xi = floe.Xi+Xi; FloeNEW.Yi = floe.Yi+Yi; FloeNEW.alive = 1;
            FloeNEW.alpha_i = 0; FloeNEW.Ui = floe.Ui; FloeNEW.Vi = floe.Vi;
            FloeNEW.dXi_p = floe.dXi_p; FloeNEW.dYi_p = floe.dYi_p;
            FloeNEW.dUi_p = floe.dUi_p; FloeNEW.dVi_p = floe.dVi_p;
            FloeNEW.dalpha_i_p = 0; FloeNEW.ksi_ice = floe.ksi_ice;%FloeNEW.area/floe.area*floe.ksi_ice;
            FloeNEW.dksi_ice_p = floe.dksi_ice_p;
            FloeNEW.interactions = [];%floe.interactions;
            FloeNEW.potentialInteractions = [];%floe.potentialInteractions;
            FloeNEW.collision_force = 0;
            %         FloeNEW.fracture_force = 0;
            FloeNEW.collision_torque = 0;
            FloeNEW.OverlapArea = 0;
            FloeNEW.Stress = zeros(2);
            FloeNEW.Fx = floe.Fx*area(a(p))/floe.area;
            FloeNEW.Fy = floe.Fy*area(a(p))/floe.area;            


            Floes = [Floes FloeNEW];
            clear FloeNEW
        end
        
    end
end

if ~isempty(Floes)
    Floes=rmfield(Floes,{'poly'});
end

warning('on',id)
warning('on',id3)
end