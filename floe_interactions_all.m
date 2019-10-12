function Floe = floe_interactions_all(Floe, ocean, winds,c2_boundary, dt)


N=length(Floe);
%Floe(i).interactions=[floeNumber Fx Fy px py torque];
%Floe(i).potentialInteractions(j).floeNum
%Floe(i).potentialInteractions(j).c_alpha=Floe(floeNum).c_alpha.

x=cat(1,Floe.Xi);
y=cat(1,Floe.Yi);
alive=cat(1,Floe.alive);
rmax=cat(1,Floe.rmax);

for i=1:N  %do interactions with boundary in a separate parfor loop
    
    Floe(i).interactions=[];
    
    Floe(i).potentialInteractions=[];
    
    Floe(i).collision_force=[0 0];
    
    Floe(i).collision_torque=0;
    
    k=1;
    
    if ( alive(i) && ~isnan(x(i)) )
        for j=1:N
            %display(j);
            if j>i && alive(j) && sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2)<(rmax(i)+rmax(j)) % if floes are potentially overlapping
                Floe(i).potentialInteractions(k).floeNum=j;
                Floe(i).potentialInteractions(k).c=[Floe(j).c_alpha(1,:)+x(j); Floe(j).c_alpha(2,:)+y(j)];
                k=k+1;
            end
            
        end
        
    end
    
end


parfor i=1:N  %now the interactions could be calculated in a parfor loop!
    
    
    
    c1=[Floe(i).c_alpha(1,:)+x(i); Floe(i).c_alpha(2,:)+y(i)];
    
    if ~isempty(Floe(i).potentialInteractions)
        
        for k=1:length(Floe(i).potentialInteractions)
            
            floeNum=Floe(i).potentialInteractions(k).floeNum;
            
            c2=Floe(i).potentialInteractions(k).c;
            
            [force_j,P_j,worked] = floe_interactions(c1,c2);
            
            if ~worked, disp(['contact points issue for (' num2str(i) ',' num2str(floeNum) ')' ]); end
            
            if sum(abs(force_j))~=0
                Floe(i).interactions=[Floe(i).interactions ; floeNum*ones(size(force_j,1),1) force_j P_j zeros(size(force_j,1),1)];
            end
            
        end
        
    end
    
    [force_b, P_j, worked] = floe_interactions(c1, c2_boundary);
    if ~worked, display(['contact points issue for (' num2str(i) ', boundary)' ]); end
    if sum(abs(force_b))~=0,
        % boundary will be recorded as floe number Inf;
        Floe(i).interactions=[Floe(i).interactions ; Inf*ones(size(force_b,1),1) force_b P_j zeros(size(force_b,1),1)];
    end
    
end



%Fill the lower part of the interacton matrix (floe_i,floe_j) for floes with j<i
for i=1:N %this has to be done sequentially
      
    if ~isempty(Floe(i).interactions)
        
        a=Floe(i).interactions;
        
        indx=a(:,1);
        
        for j=1:length(indx)
            
            if indx(j)<=N && indx(j)>i
                Floe(indx(j)).interactions=[Floe(indx(j)).interactions; i -a(j,2:3) a(j,4:5) 0];   % 0 is torque here that is to be calculated below
            end
            
        end
        
    end
    
end

% calculate all torques from forces
parfor i=1:N
    
    if ~isempty(Floe(i).interactions)
        
       a=Floe(i).interactions;
       r=[x(i) y(i)];
        for k=1:size(a,1)
            floe_Rforce=a(k,4:5);
            floe_force=a(k,2:3);
            floe_torque=cross([floe_Rforce-r 0], [floe_force 0]);
            Floe(i).interactions(k,6)=floe_torque(3);
        end
        
       Floe(i).collision_force=sum(Floe(i).interactions(:,2:3),1);
       Floe(i).collision_torque=sum(Floe(i).interactions(:,6),1);
        
    end
    
   %Do the timestepping now that forces and torques are known.
    if Floe(i).alive,
        tmp=calc_trajectory(dt,ocean, winds,Floe(i)); % calculate trajectory
        if (isempty(tmp) || isnan(x(i)) ), Floe(i).alive=0; else Floe(i)=tmp; end
    end
    
    
end



end
