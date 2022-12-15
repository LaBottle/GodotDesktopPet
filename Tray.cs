using Godot;
using System;
using System.Drawing;
using System.Windows.Forms;
using System.Threading.Tasks;

public class Tray : Node {
    public NotifyIcon Notify { get; set; }
    public ContextMenu Menu { get; set; }
    public MenuItem ExitItem { get; set; }

    public override void _Ready() {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Notify = new NotifyIcon();
        Menu = new ContextMenu();
        ExitItem = new MenuItem();
        Menu.MenuItems.AddRange(new MenuItem[] {ExitItem});
        ExitItem.Index = 0;
        ExitItem.Text = "Exit";
        ExitItem.Click += ExitItemClick;
        // ReSharper disable once StringLiteralTypo
        Notify.Icon = new Icon(@".\Assets\icon\favicon.ico");
        Notify.Text = "GodotDesktopPet";
        Notify.ContextMenu = Menu;
        Notify.Visible = true;
        Task.Run(() => {
            try {
                Application.Run();
            }
            catch (Exception ex) {
                MessageBox.Show(ex.ToString());
            }
        });
    }

    private void ExitItemClick(object sender, EventArgs e) {
        Notify.Visible = false;
        Application.Exit();
        GetTree().Quit();
    }

}