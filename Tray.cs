using Godot;
using System;
using System.Drawing;
using System.Windows.Forms;
using System.Threading.Tasks;

// ReSharper disable once CheckNamespace
public class Tray : Node {

    public NotifyIcon Notify { get; set; } = new NotifyIcon();
    public ContextMenu Menu { get; set; } = new ContextMenu();
    public MenuItem ExitItem { get; set; } = new MenuItem();
    public MenuItem VarietyChangeItem { get; set; } = new MenuItem();

    public enum Variety {
        Black,
        Brown,
        White
    }

    public MenuItem VarietyBlackItem { get; set; } = new MenuItem();
    public MenuItem VarietyBrownItem { get; set; } = new MenuItem();
    public MenuItem VarietyWhiteItem { get; set; } = new MenuItem();

    public override void _Ready() {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Menu.MenuItems.AddRange(new MenuItem[] {VarietyChangeItem, ExitItem});

        VarietyChangeItem.Index = 0;
        VarietyChangeItem.Text = "品种";
        VarietyChangeItem.MenuItems.AddRange(new[]
            {VarietyBlackItem, VarietyBrownItem, VarietyWhiteItem});
        VarietyBlackItem.RadioCheck = true;
        VarietyBrownItem.RadioCheck = true;
        VarietyWhiteItem.RadioCheck = true;
        switch ((Variety) GetParent().GetNode("Pet").Get("pet_variety")) {
            case Variety.Black:
                VarietyBlackItem.Checked = true;
                break;
            case Variety.Brown:
                VarietyBrownItem.Checked = true;
                break;
            case Variety.White:
                VarietyWhiteItem.Checked = true;
                break;
            default:
                GD.PushError("ArgumentException: `pet_variety` is undefined");
                throw new ArgumentException("ArgumentException: `pet_variety` is undefined");
        }

        VarietyBlackItem.Index = 0;
        VarietyBlackItem.Text = "黑色";
        VarietyBlackItem.Click += ChangeVarietyEventHandler;

        VarietyBrownItem.Index = 1;
        VarietyBrownItem.Text = "棕色";
        VarietyBrownItem.Click += ChangeVarietyEventHandler;

        VarietyWhiteItem.Index = 2;
        VarietyWhiteItem.Text = "白色";
        VarietyWhiteItem.Click += ChangeVarietyEventHandler;

        ExitItem.Index = 1;
        ExitItem.Text = "退出";
        ExitItem.Click += ExitItemClickEventHandler;

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
                GD.PushError(ex.ToString());
                throw;
            }
        });
    }

    private void ExitItemClickEventHandler(object sender, EventArgs e) {
        GetTree().Quit();
    }

    public override void _ExitTree() {
        if (Application.AllowQuit) {
            Notify.Visible = false;
            Application.Exit();
        }
    }

    private void ChangeVarietyEventHandler(object sender, EventArgs e) {
        Variety variety;
        if (sender == VarietyBlackItem) {
            variety = Variety.Black;
            VarietyBlackItem.Checked = true;
            VarietyBrownItem.Checked = false;
            VarietyWhiteItem.Checked = false;
        }
        else if (sender == VarietyBrownItem) {
            variety = Variety.Brown;
            VarietyBlackItem.Checked = false;
            VarietyBrownItem.Checked = true;
            VarietyWhiteItem.Checked = false;
        }
        else if (sender == VarietyWhiteItem) {
            variety = Variety.White;
            VarietyBlackItem.Checked = false;
            VarietyBrownItem.Checked = false;
            VarietyWhiteItem.Checked = true;
        }
        else {
            GD.PushError("ArgumentException: `sender` is not included in `VarietyChangeItem`");
            throw new ArgumentException(
                "ArgumentException: `sender` is not included in `VarietyChangeItem`");
        }

        GetParent().GetNode("Pet").Call("set_variety", variety);
    }

}