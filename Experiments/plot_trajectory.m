%load('map.mat');
load('model.mat');
load('trajectory.mat');

% We want one complete lap from the trajectory
starts = find(sign(trajectory.S(2:end,4) - trajectory.S(1:end-1,4)) < 0);
starts = starts + 1;

% We use only the first complete lap to build the map
trajectory.S = trajectory.S(starts(1):starts(2)-1,:);
trajectory.U = trajectory.U(starts(1):starts(2)-1,:);
trajectory.T = trajectory.T(starts(1):starts(2)-1,:);

map = build_map(trajectory.S, trajectory.T);

p = Plotter(map);
window = 500:700;%697:710;
traj.S = trajectory.S(window,:);
traj.U = trajectory.U(window,:);
traj.T = trajectory.T(window,:);
p.addTrial(traj, 'b');

sim.S = zeros(size(traj.S));
sim.U = traj.U;
sim.T = traj.T;

sim.S(1,:) = traj.S(1,:);
s = sim.S(1,:)';
for t = window(1):window(end)-1
    u = sim.U(t-window(1)+1,:)';
    dt = sim.T(t-window(1)+2) - sim.T(t-window(1)+1);
    s_next = f(s, u, dt, model, map);
    sim.S(t-window(1)+2,:) = s_next';
    
    s = s_next;
end

p.addTrial(sim, 'k');

figure;
ylabels = {'x', 'y', '\omega', 'p', 'q', '\alpha'};
%locations = {'NorthEast', 'NorthEast', 'SouthWest', 'SouthEast', 'NorthWest', 'NorthWest'};
for i = 1:6
    subplot(3,2,i);
    plot(traj.T, traj.S(:,i), '--r', sim.T, sim.S(:,i), '-b');
    %legend('Real', 'Predicted', 'Location', locations{i});
    xlabel('t (s)');
    ylabel(ylabels(i));
end

figure;
subplot(1,2,1);
plot(traj.T, traj.U(:,1));
xlabel('t (s)');
title('u1');

subplot(1,2,2);
plot(traj.T, traj.U(:,2));
title('u2');
xlabel('t (s)');