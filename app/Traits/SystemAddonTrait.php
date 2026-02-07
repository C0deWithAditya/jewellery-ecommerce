<?php

namespace App\Traits;

trait SystemAddonTrait
{
    /**
     * @return array
     */
    public function get_addons(): array
    {
        $dir = base_path('Modules');
        $directories = is_dir($dir) ? self::getDirectories($dir) : [];

        $addons = [];
        foreach ($directories as $directory) {
            $sub_dirs = is_dir($dir . '/' . $directory) ? self::getDirectories($dir . '/' . $directory) : [];
            if (in_array('Addon', $sub_dirs)) {
                $addons[] = $dir . '/' . $directory;
            }
        }

        $array = [];
        foreach ($addons as $item) {
            $full_data = include($item . '/Addon/info.php');
            $array[] = [
                'addon_name' => $full_data['name'],
                'software_id' => $full_data['software_id'],
                'is_published' => $full_data['is_published'],
            ];
        }

        return $array;
    }

    /**
     * @return array
     */
    public function get_addon_admin_routes(): array
    {
        $dir = base_path('Modules');
        $directories = is_dir($dir) ? self::getDirectories($dir) : [];
        $addons = [];
        foreach ($directories as $directory) {
            $sub_dirs = is_dir($dir . '/' . $directory) ? self::getDirectories($dir . '/' . $directory) : [];
            if (in_array('Addon', $sub_dirs)) {
                $addons[] = $dir . '/' . $directory;
            }
        }

        $full_data = [];
        foreach ($addons as $item) {
            $info = include($item . '/Addon/info.php');
            if ($info['is_published']){
                $full_data[] = include($item . '/Addon/admin_routes.php');
            }
        }

        return $full_data;
    }

    /**
     * @return array
     */
    public function get_payment_publish_status(): array
    {
        $dir = base_path('Modules'); // Update the directory path to Modules/Gateways
        $directories = is_dir($dir) ? self::getDirectories($dir) : [];
        // dd($directories);
        $addons = [];
        foreach ($directories as $directory) {
            $sub_dirs = is_dir($dir . '/' . $directory) ? self::getDirectories($dir . '/' . $directory) : []; // Use $dir instead of 'Modules/'
            if($directory == 'Gateways'){
                if (in_array('Addon', $sub_dirs)) {
                    $addons[] = $dir . '/' . $directory; // Use $dir instead of 'Modules/'
                }
            }
        }

        $array = [];
        foreach ($addons as $item) {
            $full_data = include($item . '/Addon/info.php');
            $array[] = [
                'is_published' => $full_data['is_published'],
            ];
        }


        return $array;
    }


    /**
     * @param string $path
     * @return array
     */
    function getDirectories(string $path): array
    {
        $directories = [];
        if (!is_dir($path)) return [];
        $items = scandir($path);
        foreach ($items as $item) {
            if ($item == '..' || $item == '.')
                continue;
            if (is_dir($path . '/' . $item))
                $directories[] = $item;
        }
        return $directories;
    }
}
