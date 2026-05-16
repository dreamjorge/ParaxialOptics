% Legacy: GenerateAbsHermiteHankels.m
close(figure(3))
fig3 = figure(3);
fig3.Position = [680 123 773 855];
ha = tight_subplot(2,2,[.01 .01],[.05 .01],[.1 .01]);
axes(ha(1))
plotOpticalField(scaleX*x,x/InitialWaist,abs(H22+H21).^2,mapgreen,'$x$','$y$');
axis square
ha(1).XAxis.Visible = 'off';
ha(1).YAxisLocation = 'left';
title('$a)|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,1}|^2$','interpreter','latex','FontSize',18)
% title('$a)$','interpreter','latex','FontSize',18)
set(gca,'FontSize',18);
axes(ha(2))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H22+H11).^2,mapgreen,'$x$','$y$');
axis square
title('$b)|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,2}|^2$','interpreter','latex','FontSize',18)
%title('$b)$','interpreter','latex','FontSize',18)
ha(2).XAxis.Visible = 'off';
ha(2).YAxis.Visible = 'off';
ha(2).YAxisLocation = 'right';
set(gca,'FontSize',18);
axes(ha(3))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H22+H21+H11).^2,mapgreen,'$x$','$y$');
axis square
title('$c)|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,1}+\psi_{n,m}^{2,2}|^2$','interpreter','latex','FontSize',18)
%title('$c)$','interpreter','latex','FontSize',18)
set(gca,'FontSize',18);
ha(3).YAxisLocation = 'left';
axes(ha(4))
plotOpticalField(x/InitialWaist,x/InitialWaist,abs(H22+H21+H11+H12).^2,mapgreen,'$x$','$y$');
axis square
title('$d)|\psi_{n,m}^{1,1}+\psi_{n,m}^{2,1}+\psi_{n,m}^{1,2}+\psi_{n,m}^{2,2}|^2$','interpreter','latex','FontSize',18)
%title('$d)$','interpreter','latex','FontSize',18)
ha(4).YAxisLocation = 'right';
ha(4).YAxis.Visible = 'off';
set(gca,'FontSize',18);
% sgtitle('Superposition of Hankels','FontSize',18)
%saveas(gcf,'SuperpositionOfHankels.png')
export_fig('SuperpositionOfHankels','-png','-transparent')
